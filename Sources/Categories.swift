//
//  Categories.swift
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

extension String {
    /// 引用标识
    public enum Quote: String {
        /// 单引号，
        /// - attention: 在`Process`脚本中尽量别使用此引号，可能会导致反馈找不到该路径
        case single = "'"
        /// 双引号
        /// - attention: 在`AppleScript`下使用可能会引起脚本识别错误
        case double = "\""
        /// 转译双引号
        /// - attention: 一般只用于`AppleScript`必须用双引号的情况下
        case backslashDouble = "\\\""
    }
    
    /// `'xxx', "xxx", \"xxx\"...`
    public func quote(_ qt: Quote) -> String {
        qt.rawValue + self + qt.rawValue
    }
}
