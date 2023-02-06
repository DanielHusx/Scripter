//
//  Ruby.swift
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

/// `ruby`脚本语言
public struct Ruby: Script {
    public var path: String?
    public var arguments: [String]?
    public var type: ScriptType
    
    public init(path: String?, arguments: [String]?, type: ScriptType) {
        self.path = path
        self.arguments = arguments
        self.type = type
    }
    
    /// ruby构建基本命令
    public init(_ type: ScriptType = .process(isIgnoreOutput: false, environment: .LANG_en_US, input: nil)) {
        self.init(.ruby, type: type)
    }
    
    /// ruby通用命令
    /// - Parameters:
    ///   - options: RubyOption
    ///   - programFile: .rb程序路径，默认为RubyScript.PBXProjScript
    ///   - programOptions: .rb程序参数
    /// - Returns: Self
    public func ruby_command(options: [RubyOption]? = nil,
                             programFile: String? = RubyScript.PBXProjScript,
                             programOptions: [String]? = nil) -> Self {
        var arguments = self.arguments ?? []
        
        if let options = options { arguments.append(contentsOf: options.compactMap { $0.rawValue }) }
        if let programFile = programFile { arguments.append(programFile) }
        if let programOptions = programOptions { arguments.append(contentsOf: programOptions) }
        
        return duplicate(arguments)
    }
}

extension Ruby {
    /// ruby可选项
    public struct RubyOption: Hashable {
        public let rawValue: String
        public init(rawValue: String) { self.rawValue = rawValue }
        
        /// 设置警告级别 0=silence, 1=medium, 2=verbose (default)
        public static func warningLevel(_ level: WarningLevel) -> Self {
            Self(rawValue: "-W\(level.rawValue)")
        }
        
        /// 警告级别
        public enum WarningLevel: Int {
            case silence = 0
            case medium = 1
            case verbose = 2
        }
    }
    
    
    /// Ruby本地脚本
    public struct RubyScript {
        /// 本地ruby脚本
        ///
        ///     $ruby PBXProjScript.rb /path/to/xxx.xcodeproj Debug '{"targetName":{"CODE_SIGN_STYLE":"Manual"}}'
        ///
        public static let PBXProjScript: String? = Bundle.module.path(forResource: "PBXProjScript", ofType: "rb")
    }
}
