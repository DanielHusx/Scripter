//
//  Script.swift
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

/// 脚本模型
public protocol Script {
    /// 脚本在本地的完整路径
    var path: String? { get set }
    /// 脚本参数集
    var arguments: [String]? { get set }
    /// 脚本类型
    var type: ScriptType { get set }
    
    init(path: String?, arguments: [String]?, type: ScriptType)
}

extension Script {
    
    /// 命令结合
    /// - Parameters:
    ///   - other: 其他命令
    ///   - separator: 结合符号
    /// - Returns: Self
    public func combine(_ other: Script, separatedBy separator: ScriptSeparator?) -> Self {
        var arguments = self.arguments ?? []
        
        if let separator = separator { arguments.append(separator.rawValue) }
        
        if let otherPath = other.path { arguments.append(otherPath) }
        if let otherArguments = other.arguments { arguments.append(contentsOf: otherArguments) }
        
        return duplicate(arguments)
    }
    
    /// 终端shell命令
    public var shell: String {
        let pathString = path ?? ""
        let argumentsString = arguments?.joined(separator: " ") ?? ""
        return pathString + " " + argumentsString
    }
    
    /// Apple脚本完整命令
    public var appleScript: String {
        // eg: do shell script "sudo which git" with administrator privileges
        let ret = "do shell script \"\(shell)\""
        guard type.isAsAdministrator else { return ret }
        return "\(ret) with administrator privileges"
    }
    
    /// 复制一份新对象变更参数列表
    public func duplicate(_ arguments: [String]?) -> Self {
        .init(path: path, arguments: (arguments?.isEmpty ?? true) ? nil : arguments, type: type)
    }
}
