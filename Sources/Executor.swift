//
//  Executor.swift
//
//  Copyright (c) 2023 Daniel
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//
    

import Foundation
import Combine


extension Script {
    /// 脚本执行
    public func execute() -> ScriptResultAnyOption {
        ScriptExecutor.shared.execute(self)
    }
    
    /// 脚本中断
    public static func interrupt() {
        ScriptExecutor.shared.interrupt()
    }
    
    /// 输出流
    public static func stream() -> AnyPublisher<ScriptResultAnyOption, Never>? {
        ScriptExecutor.shared.stream.eraseToAnyPublisher()
    }
}

/*
 执行脚本类特点
 - NSUserScriptTask: 忽略输入输出，无参数执行任意脚本路径文件
 - NSUserUnixTask: unix程序一般是shell，可控制入参，输入输出及错误输出。沙盒情况下只读FileManager.SearchPathDirectory.applicationScriptsDirectory下且不可写
 - NSUserAppleScriptTask: 同NSUserUnixTask的Apple脚本程序
 - NSUserAutomatorTask: 同NSUserUnixTask的工作流脚本程序
 */

/// 脚本统一执行者
struct ScriptExecutor {
    /// 单例对象
    static let shared = ScriptExecutor()
    /// 统一输出流（正常/错误管道）
    var stream: PassthroughSubject<ScriptResultAnyOption, Never> = .init()
    
    /// 取消器
    private var cancellable = Set<AnyCancellable>()
    /// 执行处理者
    private var handler: ExecutorHandlerObject
    
    private init() {
        let apple = AppleScriptExecutor()
        let process = ProcessExecutor()
        
        apple.setNext(process)
        
        self.handler = apple
        // 订阅流
        process.stream.subscribe(stream).store(in: &cancellable)
    }
}

extension ScriptExecutor {
    /// 执行脚本
    func execute(_ script: Script) -> ScriptResultAnyOption {
        do {
            let ret = try handler.execute(script)
            return .success(ret)
        } catch {
            switch error {
            case is ScriptError: return .failure(error as! ScriptError)
            default: return .failure(.executeFailed(script: script.shell, reason: ""))
            }
        }
    }
    
    /// 中断脚本
    func interrupt() {
        handler.interrupt()
    }
}


// MARK: - 执行者协议
/// 执行者协议
protocol ExecutorHandler: AnyObject {
    associatedtype ExecutorResult
    
    /// 下一责任者
    var next: (any ExecutorHandler)? { get set }
    /// 设置下一责任者
    @discardableResult
    func setNext(_ handler: any ExecutorHandler) -> any ExecutorHandler
    
    /// 执行脚本
    func execute(_ script: Script) throws -> ExecutorResult
    /// 中断执行
    func interrupt()
    
}

extension ExecutorHandler {
    @discardableResult
    func setNext(_ handler: any ExecutorHandler) -> any ExecutorHandler {
        next = handler
        return handler
    }
    
}

// MARK: - 基础类
class ExecutorHandlerObject: ExecutorHandler {
    typealias ExecutorResult = Any?
    
    var next: (any ExecutorHandler)?
    
    func execute(_ script: Script) throws -> ExecutorResult {
        guard let next = next else {
            throw ScriptError.cannotHandleScript(scriptType: script.type)
        }
        
        return try next.execute(script)
    }
    
    func interrupt() {
        next?.interrupt()
    }
}


// MARK: - AppleScript脚本
class AppleScriptExecutor: ExecutorHandlerObject {
    /// 锁
    private let lock = NSLock()
    
    /// 执行脚本
    override func execute(_ script: Script) throws -> ExecutorResult {
        // 非AppleScript不执行
        guard script.type.isApple else { return try super.execute(script) }
        
        return try execute(appleScript: script)
    }
}

extension AppleScriptExecutor {
    /// 内部执行
    private func execute(appleScript script: Script) throws -> ExecutorResult {
        try check(script)
        
        // 用锁因为一旦同一时间有两个命令正在执行NSAppleScript就有可能崩溃
        lock.lock()
        let ret = try execute(source: script.appleScript)
        lock.unlock()
        
        return ret
    }
    
    /// 校验脚本有效性
    private func check(_ script: Script) throws {
        // 路径是否有值
        guard let path = script.path, !path.isEmpty else {
            throw ScriptError.scriptInvalid(reason: .pathEmpty)
        }
    }
    
    /// 执行Apple脚本
    private func execute(source: String) throws -> ExecutorResult {
        let scriptor = NSAppleScript(source: source)
        var errorInfo: NSDictionary? = nil
        
        guard let result = scriptor?.executeAndReturnError(&errorInfo) else {
            return try errorResult(source, errorInfo: errorInfo)
        }
        
        return result.stringValue
    }
}

extension AppleScriptExecutor {
    /// 错误结果处理
    private func errorResult(_ source: String, errorInfo: NSDictionary?) throws -> ExecutorResult {
        // 反馈错误
        let errorMessage = errorInfo?.value(forKey: NSAppleScript.errorMessage) as? String
        
        // 这种情况属于没有输出、对于shell命令来说是正确的
        // 但对于apple script就会抛出错误，所以此处做拦截
        // 返回上层output、error都为空但是 return 为nil
        guard errorMessage != "The command exited with a non-zero status." else {
            return nil
        }
        
        let errorCode = (errorInfo?.value(forKey: NSAppleScript.errorNumber) as? NSNumber)?.intValue
        let reason = errorReason(code: errorCode, message: errorMessage)
        
        throw ScriptError.executeFailed(script: source, reason: reason)
    }
    
    /// 错误原因描述
    private func errorReason(code: Int?, message: String?) -> String {
        let ret = message ?? ScriptLocalized.localized_unknownError
        guard let code = code else { return ret }
        
        return ret + " [code: \(code)]"

    }
}


// MARK: - Shell脚本
class ProcessExecutor: ExecutorHandlerObject {
    /// 流输出，当isIgnoreOutput为true时方可生效
    var stream: PassthroughSubject<ScriptResultAnyOption, Never> = .init()
    
    /// 执行的命令池
    private var processes: [Process] = []
    /// 锁
    private let lock = NSLock()
    
    override func execute(_ script: Script) throws -> ExecutorResult {
        guard script.type.isProcess else { return try super.execute(script) }
        
        return try execute(script: script)
    }
    
    override func interrupt() {
        // 没有恢复机制，就先直接终止
        for process in processes { terminate(process) }
        
        super.interrupt()
    }
}

extension ProcessExecutor {
    /// 内部执行脚本
    private func execute(script: Script) throws -> ExecutorResult {
        try check(script)
        
        // 缓存起来
        let process = process(script: script)
        append(process)
        
        return try execute(process: process)
    }
    
    /// 校验脚本有效性
    private func check(_ script: Script) throws {
        // 路径是否有值
        guard let path = script.path, !path.isEmpty else {
            throw ScriptError.scriptInvalid(reason: .pathEmpty)
        }
        
        // 校验脚本文件是否存在且是否是非文档路径
        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory), !isDirectory.boolValue else {
            throw ScriptError.scriptInvalid(reason: .pathNotExistOrIsDirectory(path: path))
        }
        
        // 判断脚本是否有执行权限
        guard FileManager.default.isExecutableFile(atPath: path) else {
            throw ScriptError.scriptInvalid(reason: .pathPermissionDenied(path: path))
        }
    }
    
    /// 执行脚本
    private func execute(process: Process) throws -> ExecutorResult {
        // 执行脚本
        if #available(macOS 13.0, *) {
            try process.run()
        } else {
            process.launch()
        }
        // 等待执行完毕
        process.waitUntilExit()
        
        // 执行结果解析
        return try result(process: process)
    }
    
    /// 终止
    private func terminate(_ process: Process?) {
        guard process?.isRunning ?? false else { return }
        
        process?.terminate()
    }
    
    /// 中断
    private func interrupt(_ process: Process?) {
        guard process?.isRunning ?? false else { return }
        
        process?.interrupt()
    }
}

extension ProcessExecutor {
    /// 解析结果
    private func result(process: Process) throws -> ExecutorResult {
        // 判断是否是非正常结束，算执行失败
        guard process.sc_isSuccess else { return try errorResult(process) }
        
        // 正常结束下，理论上不会有错误打印，即便有也忽略它
        return process.sc_outputStream
    }
    
    /// 错误结果处理
    private func errorResult(_ process: Process) throws {
        let reason = errorReason(code: process.terminationStatus,
                                 reason: process.terminationReason,
                                 outputs: process.sc_errorStream)
        let script = process.shell
        
        throw ScriptError.executeFailed(script: script, reason: reason)
    }
    
    /// 错误原因
    private func errorReason(code: Int32, reason: Process.TerminationReason, outputs: String?) -> String {
        let ret = outputs ?? ScriptLocalized.localized_unknownError
        return ret + " [code: \(code)] [reason: \(reason.sc_reason)]"
    }
}

extension ProcessExecutor {
    /// `Script -> Process`
    private func process(script: Script) -> Process {
        let process = Process()
        
        process.executableURL = URL(fileURLWithPath: script.path!)
        process.arguments = script.arguments ?? []
        // 未设置环境时不能设置env，不然其内部无法继承内部的env，从而可能导致xcodebuild archive异常
        if let env = script.type.environment, !env.isEmpty { process.environment = env }
        
        process.sc_ignoreOutput = script.type.isIgnoreOutput
        
        // terminationHandler并不一定在waitUtilExit()之后回调
        process.terminationHandler = { [weak self] p in
            // 结束时清除输入输出，不然会导致CPU暴增
            self?.clean(stream: p)
            self?.remove(p)
        }
        
        // 存在输入文件，读取文件内容为数据
        if let input = script.type.inputFile,
           let contents = try? String(contentsOfFile: input).data(using: .utf8),
           !contents.isEmpty {
            // 输入管道
            let inPipe = Pipe()
            inPipe.fileHandleForWriting.writeabilityHandler = { handler in
                try? handler.write(contentsOf: contents)
            }
            
            process.standardInput = inPipe
        }
        
        // 正常输出管道
        let outPipe = Pipe()
        outPipe.fileHandleForReading.readabilityHandler = { [weak self, weak process] handler in
            guard let s = String(data: handler.availableData, encoding: .utf8),
                  !s.isEmpty else { return }
            
            self?.stream.send(.success(s))
            
            // 不忽略则加入到缓存中
            guard !(process?.sc_ignoreOutput ?? true) else { return }
            
            process?.sc_outputStream.append(s.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        process.standardOutput = outPipe
        
        // 错误输出管道
        let errPipe = Pipe()
        errPipe.fileHandleForReading.readabilityHandler = { [weak self, weak process] handler in
            guard let s = String(data: handler.availableData, encoding: .utf8),
                  !s.isEmpty else { return }
            
            self?.stream.send(.failure(.executeFailed(script: process?.shell ?? "", reason: s)))
            
            // 不忽略则加入到缓存中
            guard !(process?.sc_ignoreOutput ?? true) else { return }
            
            process?.sc_errorStream.append(s.trimmingCharacters(in: .whitespacesAndNewlines))
            
        }
        
        process.standardError = errPipe
        
        return process
    }
    
    /// 清理流及其关联，并关闭
    private func clean(stream process: Process?) {
        if let pipe = process?.standardOutput as? Pipe {
            try? pipe.fileHandleForReading.close()
            pipe.fileHandleForReading.readabilityHandler = nil
        }
        
        if let pipe = process?.standardError as? Pipe {
            try? pipe.fileHandleForReading.close()
            pipe.fileHandleForReading.readabilityHandler = nil
        }
        
        if let pipe = process?.standardInput as? Pipe {
            try? pipe.fileHandleForWriting.close()
            pipe.fileHandleForWriting.writeabilityHandler = nil
        }
    }
}

extension ProcessExecutor {
    /// 添加缓存
    private func append(_ process: Process) {
        lock.lock()
        processes.append(process)
        lock.unlock()
    }
    
    /// 移除缓存
    private func remove(_ process: Process?) {
        guard let process = process else { return }
        
        lock.lock()
        processes.removeAll(where: { process == $0 })
        lock.unlock()
    }
}

// MARK: Process Extension
extension Process {
    internal struct AssociateKeys {
        static var sc_ignoreOutput = "sc_ignoreOutput"
        static var sc_outputStream = "sc_outputStream"
        static var sc_errorStream = "sc_errorStream"
    }
    
    /// 执行结果是否成功
    internal var sc_isSuccess: Bool { terminationStatus == 0 }
    
    /// 是否忽略输出
    internal var sc_ignoreOutput: Bool {
        get {
            guard let ret = objc_getAssociatedObject(self, &AssociateKeys.sc_ignoreOutput) as? Bool else {
                return false
            }
            return ret
        }
        set { objc_setAssociatedObject(self, &AssociateKeys.sc_ignoreOutput, newValue, .OBJC_ASSOCIATION_ASSIGN) }
    }
    /// 输出流
    internal var sc_outputStream: String {
        get {
            guard let ret = objc_getAssociatedObject(self, &AssociateKeys.sc_outputStream) as? String else {
                return ""
            }
            return ret
        }
        set { objc_setAssociatedObject(self, &AssociateKeys.sc_outputStream, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    /// 错误流
    internal var sc_errorStream: String {
        get {
            guard let ret = objc_getAssociatedObject(self, &AssociateKeys.sc_errorStream) as? String else {
                return ""
            }
            return ret
        }
        set { objc_setAssociatedObject(self, &AssociateKeys.sc_errorStream, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    /// Shell完整命令
    internal var shell: String {
        let pathString = executableURL?.absoluteString ?? ""
        let argumentsString = arguments?.joined(separator: " ") ?? ""
        
        return pathString + " " + argumentsString
    }
}
