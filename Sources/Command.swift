//
//  Command.swift
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

extension Script {
    /// 命令基于缓存脚本路径进行初始化
    /// - Parameters:
    ///   - command: 命令对象封装获取方式与类型
    ///   - arguments: 参数集
    ///   - type: 脚本类型
    public init(
        _ command: ScriptCommand,
        arguments: [String]? = nil,
        type: ScriptType = .unknown
    ) {
        self.init(
            path: command.path,
            arguments: arguments,
            type: type
        )
    }
}

public struct ScriptCommand {
    /// 命令标识（脚本名）
    public let rawValue: String
    /// 获取命令方式，默认以`whereis`命令获取
    public var fetcher: (String) -> String?
    
    
    /// 初始化
    /// - Parameters:
    ///   - rawValue: 脚本名
    ///   - fetcher: 获取脚本路径的方式，默认使用`whereis`获取
    public init(
        _ rawValue: String,
        fetcher: @escaping (String) -> String? = fetchBy(whereis:)
    ) {
        self.rawValue = rawValue
        self.fetcher = fetcher
    }
    
    
    /// 以自定义脚本路径的方式初始化
    /// - Parameters:
    ///   - rawValue: 脚本名
    ///   - path: 默认脚本路径
    public init(
        _ rawValue: String,
        path: String?
    ) {
        self.init(
            rawValue,
            fetcher: { _ in path }
        )
    }
}



extension ScriptCommand: Hashable {
    public static func == (lhs: ScriptCommand, rhs: ScriptCommand) -> Bool {
        lhs.rawValue == rhs.rawValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}


extension ScriptCommand {
    /// 缓存已获取的脚本
    private static var scriptPaths: [Self: String] = [:]
    /// 用户字典存取的脚本列表键
    private static let kPathInUserDefaultsKey = "Serendipity_ScriptCommands"
    
    /// 脚本路径
    public var path: String? {
        // 读缓存
        if let ret = Self.scriptPaths[self] { return ret }
        // 读用户字典
        // 此处做路径检查，是为了防止脚本路径相较之前不一致后无法重新更新
        // 不正常的脚本路径存不存字典内无关紧要
        if let commandDict = UserDefaults.standard.dictionary(forKey: ScriptCommand.kPathInUserDefaultsKey),
           let ret = commandDict[rawValue] as? String,
           FileManager.default.fileExists(atPath: ret) {
            return ret
        }
        
        // 自定义获取脚本路径
        // 此处不做路径检查，是为了让path不局限于具体脚本
        guard let ret = fetcher(rawValue) else { return nil }
        
        // 写缓存
        Self.scriptPaths[self] = ret
        // 写用户字典
        var dict: [String: Any] = UserDefaults.standard.dictionary(forKey: ScriptCommand.kPathInUserDefaultsKey) ?? [:]
        dict[rawValue] = ret
        UserDefaults.standard.set(dict, forKey: ScriptCommand.kPathInUserDefaultsKey)
        
        return ret
    }
    
    /// 清除本地缓存命令
    public static func cleanDiskCache() {
        UserDefaults.standard.removeObject(forKey: ScriptCommand.kPathInUserDefaultsKey)
    }
}

// MARK: - 基础查找脚本路径方法
extension ScriptCommand {
    /// `whereis`查找命令
    public static func fetchBy(whereis commandString: String) -> String? {
        Whereis(path: whereis.rawValue,
                arguments: nil,
                type: .apple(isAsAdministrator: false))
            .pureScriptPath(commandString)
            .execute()
            .string
    }
    
    /// ```eval `/usr/libexec/path_helper -s`; which``` 构建查找命令
    /// 主要用于`ruby`类的命令查找
    public static func fetchBy(eval commandString: String) -> String? {
        Eval(path: eval.path,
             arguments: nil,
             type: .apple(isAsAdministrator: false))
            .eval_which_command(commandString)
            .execute()
            .string
    }
    
    /// `which`查找命令
    public static func fetchBy(which commandString: String) -> String? {
        Which().command(commandString)
               .execute()
               .string
    }
    
}

// MARK: - 基础命令定义
extension ScriptCommand {
    
    /// 此脚本路径非正常脚本路径，单纯为解决其他脚本环境未能正确获取的问题
    /// ```
    /// eval `/usr/libexec/path_helper -s`;
    /// ```
    public static let eval = Self("eval") { script in
        guard let path_helper = fetchBy(whereis: "path_helper") else { return nil }
        return "eval `\(path_helper) -s`;"
    }
    // 不设置默认路径为 /usr/bin/whereis 是考虑系统环境可能并非所想的那么固定，由命令得到该路径相对保险些
    public static let whereis = Self("whereis")
    public static let which = Self("which")
    
    /// `echo`理论上的脚本路径：`/bin/echo`
    /// 但是存在打印不会自动转码的问题，所以固定用`echo`
    /// 这样也同样限制了此命令只能用`AppleScript`调用
    public static let echo = Self("echo", path: "echo")
    
    /// 内置`symbolicatecrash`
    public static let symbolicatecrash = Self("symbolicatecrash",
                                              // Bundle.module的接口只有在Package.swift配置正确的resource文档路径编译后才会出现
                                              path: Bundle.module.path(forResource: "symbolicatecrash",
                                                                       ofType: nil))
    

}

