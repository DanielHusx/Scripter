//
//  Whereis.swift
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

/// 查找脚本路径
public struct Whereis: Script {
    public var path: String?
    public var arguments: [String]?
    public var type: ScriptType
    
    public init(path: String?, arguments: [String]?, type: ScriptType) {
        self.path = path
        self.arguments = arguments
        self.type = type
    }
    
    /// 初始化
    public init(_ type: ScriptType = .generalApple) {
        self.init(.whereis, type: type)
    }
    
    /// whereis通用命令
    /// - Parameters:
    ///   - value: 搜索的字段，可以是命令的名称，比如 echo；也可以是搜索某个文档路径，比如 /usr/bin/*
    ///   - options: 可选项
    /// - Returns: Script
    public func command(
        _ value: String,
        options: [WhereisOption]? = nil
    ) -> Self {
        var arguments = self.arguments ?? []
        
        if let options = options { arguments.append(contentsOf: options.compactMap({ $0.rawValue })) }
        arguments.append(value)
        
        return duplicate(arguments)
    }
    
    /// 获取简洁脚本路径
    /// - Parameter value: 搜索的字段，可以是命令的名称，比如 echo；也可以是搜索某个文档路径，比如 /usr/bin/*
    public func pureScriptPath(_ value: String) -> Self {
        command(value, options: [.binary, .quiet])
    }
}


extension Whereis {
    /// whereis可选项
    public struct WhereisOption: Hashable {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        
        /// 搜索手册
        public static let manual = WhereisOption(rawValue: "-m")
        /// 搜索二进制
        public static let binary = WhereisOption(rawValue: "-b")
        /// 静默输出
        public static let quiet = WhereisOption(rawValue: "-q")
        
    }
}
