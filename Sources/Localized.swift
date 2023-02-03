//
//  Localized.swift
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
    /// 多语言
    var script_localized: String {
        NSLocalizedString(self,
                          tableName: nil,
                          bundle: Bundle(for: ScriptExecutor.self),
                          value: "",
                          comment: "")
    }
    
    /// 带参数多语言
    func script_localizedFormat(format: CVarArg...) -> String {
        String.localizedStringWithFormat(script_localized, format)
    }
}


struct ScriptLocalized {
    static let localized_unknownError = "unknown_error".script_localized
}

extension ScriptLocalized {
    static func localizedString(_ value: String) -> String {
        value.script_localized
    }
    
    static func localizedString(_ value: String, format: CVarArg...) -> String {
        value.script_localizedFormat(format: format)
    }
}

// MARK: - Script.Channel
extension ScriptLocalized {
    static let localized_adHoc = "ad_hoc".script_localized
    static let localized_appStore = "app_store".script_localized
    static let localized_development = "development".script_localized
    static let localized_enterprise = "enterprise".script_localized
    static let localized_unknownChannel = "unknown_channel".script_localized
}

// MARK: - ScriptError.ScriptInvalidReason
extension ScriptLocalized {
    static let localized_pathEmpty = "path_empty".script_localized
    
    static func localized_pathNotExistOrIsDirectory(_ path: String) -> String {
        "%@ path_not_exist_or_directory".script_localizedFormat(format: path)
    }
    static func localized_pathPermissionDenied(_ path: String) -> String {
        "%@ path_permission_denied".script_localizedFormat(format: path)
    }
    
}

// MARK: - Process.TerminationReason
extension ScriptLocalized {
    static let localized_processReasonExit = "process_reason_exit".script_localized
    static let localized_processReasonUncaughtSignal = "process_uncaught_signal".script_localized
    static func localized_unknownReason(_ value: Int) -> String {
        "unknown_reason %d".script_localizedFormat(format: value)
    }
}


// MARK: - ScriptError
extension ScriptLocalized {
    static func localized_unsupportedHandleScript(_ scriptType: ScriptType) -> String {
        "unsupported_script_type %@".script_localizedFormat(format: scriptType.description)
    }
    static func localized_invalidScript(_ reason: String) -> String {
        "invalid_script: %@".script_localizedFormat(format: reason)
    }
    static func localized_executedFailed(_ script: String, reason: String) -> String {
        "%@ executed_script_failed %@".script_localizedFormat(format: script, reason)
    }
}

extension ScriptLocalized {
    static func localized_JSONSerializationError(_ error: Error) -> String {
        "json_serialization_error".script_localizedFormat(format: "\(error)")
    }
    static func localized_PropertyListSerializationError(_ error: Error) -> String {
        "property_list_serialization_error".script_localizedFormat(format: "\(error)")
    }

}
