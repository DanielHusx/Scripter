//
//  Type.swift
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


/// 脚本类型
public enum ScriptType {
    /// 未知类型
    case unknown
    
    /// 终端Shell类型
    /// - Parameters:
    ///    - isIgnoreOutput: 是否忽略输出。如果为true，则通过Exector.xxxStreamNotify输出
    ///    - environment: 环境变量。一般为需要先以export定义某变量才能正确执行的脚本才设置
    ///    - input: 输入文件路径。脚本需要输入文件时有效
    case process(isIgnoreOutput: Bool, environment: @autoclosure () -> EnvironmentType?, input: @autoclosure () -> String?)
    
    /// 系统Apple类型
    /// - attention: arguments内的参数如果存在 "（能用'代替最好，就无需反斜杠）或其他需要转义的字符，需要使用2+1反斜杠+转义字符，例如： `git -C \\\"path/to/destination\\\"`
    /// - Parameters:
    ///    - isAsAdministrator: 是否以管理员身份执行
    case apple(isAsAdministrator: Bool)
    
    public typealias EnvironmentType = [String: String]
}


extension ScriptType {
    /// 通用型AppleScript 无需管理员身份
    public static let generalApple = apple(isAsAdministrator: false)
    /// 通用型Process 忽略输出
    public static func generalProcess(ignore: Bool = true) -> Self {
        process(isIgnoreOutput: ignore, environment: nil, input: nil)
    }
}

extension ScriptType.EnvironmentType {
    /// 开发路径变量
    public static let DEVELOPER_DIR = ["DEVELOPER_DIR": "/Applications/Xcode.app/Contents/Developer"]
    /// 语言变量 - 英文
    public static let LANG_en_US = ["LANG": "en_US.UTF-8"]
    
}

extension ScriptType {
    /// 是否是终端shell类型
    public var isProcess: Bool {
        guard case .process = self else { return false }
        return true
    }
    
    /// 是否是系统Apple
    public var isApple: Bool {
        guard case .apple = self else { return false }
        return true
    }
    
    /// 是否以管理员执行
    public var isAsAdministrator: Bool {
        guard case .apple(let admin) = self else { return false }
        return admin
    }
    
    /// 是否忽略输出
    public var isIgnoreOutput: Bool {
        guard case .process(isIgnoreOutput: let ret, environment: _, input: _) = self else { return false }
        return ret
    }
    
    /// 输入文件
    public var inputFile: String? {
        guard case .process(isIgnoreOutput: _, environment: _, input: let ret) = self else { return nil }
        return ret()
    }
    
    /// 环境变量
    public var environment: [String: String]? {
        guard case .process(_, let env, _) = self else { return nil }
        return env()
    }
}
