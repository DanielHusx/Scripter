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

/// 任意参数
public typealias AnyParameterLiteral = any ParameterLiteral

/// 参数协议，旨在标识参数类型，以区分字符串与路径类型
public protocol ParameterLiteral {
    func value(_ type: ScriptType) -> String
}

extension String: ParameterLiteral {
    public func value(_ type: ScriptType) -> String {
        self
    }
}

/// 专用标记路径类型，必要的情况下根据`ScriptType`作处理
public enum PathLiteral: ParameterLiteral {
    /// 不做任何变更的数据
    case raw(String)
    /// 内容完全为路径
    case path(String)
    /// 部分内容为路径的
    case part(part: String, path: String)
    /// 双引号引用
    case doubleQuote(part: String, content: String)
    
    public func value(_ type: ScriptType) -> String {
        switch self {
        case .raw(let string): return string
        case .path(let string):
            return convert(string, type: type, quote: .single)
        case .part(part: let part, path: let content):
            return part + convert(content, type: type, quote: .single)
        case .doubleQuote(part: let part, content: let content):
            return part + convert(content, type: type, quote: .backslashDouble)
        }
    }
    
    private func convert(_ value: String, type: ScriptType, quote: String.Quote) -> String {
        switch quote {
        case .single:
            
        case .double:
            
        case .backslashDouble:
            
        }
        type.isApple ? value.quote(quote) : value
    }
}

extension [AnyParameterLiteral] {
    /// `[AnyParameterLiteral] -> [String]`
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
    
    /// 通用构建
    /// - Parameters:
    ///   - specific: 标识
    ///   - options: 可选项
    ///   - reserve: 保留位
    ///   - before: 保留是否需要在可选项之前，默认false
    /// - Returns: `Self`
    static func common<T>(
        _ specific: String,
        options: [T]? = nil,
        reserve: [String]? = nil,
        before: Bool = false
    ) -> Self where T: ParameterOption {
        var ret: [AnyParameterLiteral] = [specific]
        
        if let options = options, !options.isEmpty {
            ret.append(contentsOf: options.compactMap({ $0.rawValue }).flatMap({ $0 }))
        }
        if let reserve = reserve, !reserve.isEmpty {
            before ? ret.insert(contentsOf: reserve, at: 1) : ret.append(contentsOf: reserve)
        }
        
        return Self(rawValue: ret)
    }
    
    static func common<T>(
        _ specific: String,
        options: [T]? = nil,
        reserve: String?,
        before: Bool = false
    ) -> Self where T: PodOptionProtocol {
        guard let reserve = reserve else { return common(specific, options: options, before: before) }
        return common(specific, options: options, reserve: [reserve], before: before)
    }
}
