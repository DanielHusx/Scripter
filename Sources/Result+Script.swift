//
//  Result+Script.swift
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

/// 结果元组
public typealias ScriptResult<Success> = Result<Success, ScriptError>
public typealias ScriptResultAnyOption = ScriptResult<Any?>

// MARK: - 扩展结果类型
extension Result {
    /// 返回类型是否是 .success
    public var isSuccess: Bool {
        guard case .success = self else { return false }
        return true
    }
    
    /// 返回类型是否是 .failure
    public var isFailure: Bool {
        !isSuccess
    }
    
    /// 返回成功关联值
    public var success: Success? {
        guard case let .success(value) = self else { return nil }
        return value
    }
    
    /// 返回失败关联值
    public var failure: Failure? {
        guard case let .failure(error) = self else { return nil }
        return error
    }
    
    /// 自定义初始化
    /// - Parameters:
    ///   - value: a value
    ///   - error: an `Error`
    public init(value: Success, error: Failure?) {
        if let error = error {
            self = .failure(error)
        } else {
            self = .success(value)
        }
    }
    
    /// `Result`转化
    public func convert<T, F>(success sc: @escaping (Success) -> T, failure fc: @escaping (Failure) -> F) -> Result<T, F> {
        switch self {
        case .success(let s): return .success(sc(s))
        case .failure(let f): return .failure(fc(f))
        }
    }
}

extension Result {
    /// 成功时的结果反馈为字符串
    public var string: String? {
        guard isSuccess, let ret = success as? String else { return nil }
        return ret
    }
    
    /// 成功时反馈结果为json字符串解析成字典
    public var jsonObject: Script.KeyValueType? {
        guard let ret = string?.jsonObject else { return nil }
        
        return ret
    }
    
    /// 成功时反馈结果为plist字符串解析成字典
    public var propertyList: Script.KeyValueType? {
        guard let ret = string?.propertyList else { return nil }
        
        return ret
    }
}

extension Result where Success == Any?, Failure == ScriptError {
    /// JSON解析字典，同时对错误结果进行包裹
    public func jsonResult() -> Self {
        guard isSuccess else {
            return .failure(.serializationFailed(reason: .scripError(error: failure)))
        }
        guard let string = success as? String,
              let data = string.data(using: .utf8),
              !data.isEmpty else {
            return .success(nil)
        }
        do {
            let ret = try JSONSerialization.jsonObject(with: data, options: []) as? Script.KeyValueType
            return .success(ret)
        } catch {
            return .failure(.serializationFailed(reason: .JSONSerializationError(error: error)))
        }
    }
    
    /// Plist解析字典，同时对错误结果进行包裹
    public func propertyListResult(_ options: PropertyListSerialization.MutabilityOptions = .mutableContainersAndLeaves) -> Self {
        guard isSuccess else {
            return .failure(.serializationFailed(reason: .scripError(error: failure)))
        }
        guard let string = success as? String,
              let data = string.data(using: .utf8),
              !data.isEmpty
        else { return .success(nil) }
        
        do {
            var format = PropertyListSerialization.PropertyListFormat.xml
            let ret = try PropertyListSerialization.propertyList(from: data, options: options, format: &format) as? Script.KeyValueType
            return .success(ret)
        } catch {
            return .failure(.serializationFailed(reason: .PropertyListSerializationError(error: error)))
        }
    }
}
