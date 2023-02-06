//
//  Parameter.swift
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

public protocol ParameterLiteral {
    func value(_ type: ScriptType) -> String
}

extension String: ParameterLiteral {
    public func value(_ type: ScriptType) -> String {
        self
    }
}

public enum PathLiteral: ParameterLiteral {
    /// 不做任何变更的数据
    case raw(String)
    /// 内容完全为路径
    case path(String)
    /// 部分内容为路径的
    case part(part: String, path: String)
    
    public func value(_ type: ScriptType) -> String {
        switch self {
        case .raw(let string): return string
        case .path(let string): return convert(string, type: type)
        case .part(part: let content, path: let path): return content + convert(path, type: type)
            
        }
    }
    
    private func convert(_ path: String, type: ScriptType) -> String {
        type.isApple ? path.appleScriptPath : path
    }
}

public typealias AnyParameterLiteral = any ParameterLiteral

extension [AnyParameterLiteral] {
    public func strings(_ type: ScriptType) -> [String] {
        compactMap({ $0.value(type) })
    }
}

public protocol ParameterOption {
    var rawValue: [AnyParameterLiteral] { get }
    init(rawValue: [AnyParameterLiteral])
}

extension ParameterOption {
    public init(rawValue: AnyParameterLiteral...) { self.init(rawValue: rawValue) }
}
