//
//  Separator.swift
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

/// 字符串分割对象
public enum ScriptSeparator: String {
    /// `:`
    case colon = ":"
    /// `.`
    case point = "."
    
    /// `||`
    case logicalOr = "||"
    /// `&&`
    case logicalAnd = "&&"
    
    /// `|`
    case operationOr = "|"
    /// `&`
    case operationAnd = "&"
}


extension ScriptSeparator {
    /// 专用于`PlistBuddy`命令实体之间分割
    public static let PlistBuddyEntrySeparator = colon
    /// 专用于`Plutil`命令键值之间分割
    public static let PlutilKeypathSeparator = point
}

extension Array where Element == String {
    /// 以拼接字符合并列表
    public func joined(separator: ScriptSeparator) -> String {
        joined(separator: separator.rawValue)
    }
}
