//
//  JSON.swift
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


extension Data {
    public func jsonObjectThrows() throws -> Script.KeyValueType? {
        try JSONSerialization.jsonObject(with: self, options: []) as? Script.KeyValueType
    }
}

extension String {
    /// json字符串 => [String: AnyHashable]
    public func jsonObjectThrows() throws -> Script.KeyValueType? {
        guard let ret = try data(using: .utf8)?.jsonObjectThrows() else { return nil }
        
        return ret
    }
}


extension Data {
    /// json数据 => [String: AnyHashable]
    public var jsonObject: Script.KeyValueType? {
        jsonAny as? Script.KeyValueType
    }
    
    /// xml数据 => [String: AnyHashable]
    public var propertyList: Script.KeyValueType? {
        propertyAny as? Script.KeyValueType
    }
    
    /// json数据 => 对象
    public var jsonAny: Any? {
        try? JSONSerialization.jsonObject(with: self, options: [])
    }
    
    /// xml数据 => 对象
    public var propertyAny: Any? {
        var format = PropertyListSerialization.PropertyListFormat.xml
        return try? PropertyListSerialization.propertyList(from: self, options: .mutableContainersAndLeaves, format: &format)
    }
    
    /// json数据 => [Scrip.BuildSetting: AnHashable]
//    public var buildSettingJsonObject: Script.BuildSettingKeyValueType? {
//        jsonObject?.mapKey({ .init(rawValue: $0) })
//    }
}

extension Script.KeyValueType {
    /// [String: AnyHashable] => json数据
    public var jsonData: Data? {
        try? JSONSerialization.data(withJSONObject: self, options: .fragmentsAllowed)
    }
    
    /// [String: AnyHashable] => xml数据
    public var propertyListData: Data? {
        try? PropertyListSerialization.data(fromPropertyList: self, format: .xml, options: .zero)
    }
    
    /// [String: AnyHashable] => json字符串
    public var jsonString: String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []),
              let json = String(data: data, encoding: .utf8) else { return nil }
        return json
    }
}

//extension Script.BuildSettingKeyValueType {
//    /// [Scrip.BuildSetting: AnHashable] => [String: AnyHashable] => json数据
//    public var jsonData: Data? {
//        try? JSONSerialization.data(withJSONObject: self.mapKey({ $0.rawValue }), options: .prettyPrinted)
//    }
//}


extension String {
    /// json字符串 => [String: AnyHashable]
    public var jsonObject: Script.KeyValueType? {
        guard let ret = data(using: .utf8)?.jsonObject else { return nil }
        
        return ret
    }
    
    /// xml字符串 => [String: AnyHashable]
    public var propertyList: Script.KeyValueType? {
        guard let ret = data(using: .utf8)?.propertyList else { return nil }
        
        return ret
    }
    
    /// json文件路径 => [String: AnyHashable]
    public var fileOfJSONObject: Script.KeyValueType? {
        guard let ret = try? Data(contentsOf: URL(fileURLWithPath: self)).jsonObject else { return nil }
        
        return ret
    }
    
    /// xml/plist文件字符串 => [String: AnyHashable]
    public var fileOfPropertyList: Script.KeyValueType? {
        guard let ret = try? Data(contentsOf: URL(fileURLWithPath: self)).propertyList else { return nil }
        
        return ret
    }
    
}
