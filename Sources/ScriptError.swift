//
//  ScriptError.swift
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

/// 脚本错误
public enum ScriptError: Error {
    /// 脚本路径失效原因
    public enum ScriptInvalidReason {
        /// 路径为空
        case pathEmpty
        /// 脚本路径不存在或路径为文档路径
        case pathNotExistOrIsDirectory(path: String)
        /// 脚本无权限访问
        case pathPermissionDenied(path: String)
    }
    /// 序列化失败原因
    public indirect enum SerializationFailedReason {
        /// 其他原因，一般是在序列化前就失败的外部原因
        case scripError(error: ScriptError?)
        /// json序列化错误
        case JSONSerializationError(error: Error)
        /// plist序列化错误
        case PropertyListSerializationError(error: Error)
    }
    
    /// 无法处理脚本
    case cannotHandleScript(scriptType: ScriptType)
    /// 脚本无效
    case scriptInvalid(reason: ScriptInvalidReason)
    /// 脚本执行失败
    case executeFailed(script: String, reason: String)
    
    /// 序列化失败
    case serializationFailed(reason: SerializationFailedReason)
}
