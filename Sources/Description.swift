//
//  Description.swift
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

//extension Script: CustomStringConvertible {
//    public var description: String {
//        switch type {
//        case .apple(isAsAdministrator: let isAsAdministrator):
//            return "[Apple Script] [admin: \(isAsAdministrator)] \(source)"
//        case .process(isIgnoreOutput: let isIgnoreOutput, environment: let environment, input: let input):
//            return "[Shell Script] [ignore: \(isIgnoreOutput), env: \(String(describing: environment)), input: \(String(describing: input))] \(shell)"
//        default: return "[Unknown Script] \(shell)"
//        }
//    }
//}

extension ScriptType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .apple: return "apple"
        case .process: return "process"
        default: return "unknown"
        }
    }
}

//extension Script.Channel: CustomStringConvertible {
//    public var description: String {
//        switch self {
//        case .ad_hoc: return ScriptLocalized.localized_adHoc
//        case .app_store: return ScriptLocalized.localized_appStore
//        case .development: return ScriptLocalized.localized_development
//        case .enterprise: return ScriptLocalized.localized_enterprise
//        default: return ScriptLocalized.localized_unknownChannel
//        }
//    }
//}
//
//extension Script.BuildSetting.Value.CODE_SIGN_IDENTITY: CustomStringConvertible {
//    public var description: String {
//        switch self {
//        case .Sign_To_Run_Locally: return "Sign to Run Locally"
//        case .Mac_App_Distribution: return "Mac App Distribution"
//        case .Mac_Installer_Distribution: return "Mac Installer Distribution"
//        case .Developer_ID_Application: return "Developer ID Application"
//        case .Developer_ID_Installer: return "Developer ID Installer"
//        default: return rawValue
//        }
//    }
//}

extension ScriptError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .cannotHandleScript(scriptType: let t): return ScriptLocalized.localized_unsupportedHandleScript(t)
        case .scriptInvalid(reason: let r): return ScriptLocalized.localized_invalidScript(r.description)
        case .executeFailed(script: let s, reason: let r): return ScriptLocalized.localized_executedFailed(s, reason: r)
        case .serializationFailed(reason: let r): return r.description
        }
    }
}

extension ScriptError.SerializationFailedReason: CustomStringConvertible {
    public var description: String {
        switch self {
        case .scripError(let error): return error?.description ?? ScriptLocalized.localized_unknownError
        case .JSONSerializationError(let error): return ScriptLocalized.localized_JSONSerializationError(error)
        case .PropertyListSerializationError(let error): return ScriptLocalized.localized_PropertyListSerializationError(error)
        }
    }
}

extension ScriptError.ScriptInvalidReason: CustomStringConvertible {
    public var description: String {
        switch self {
        case .pathEmpty: return ScriptLocalized.localized_pathEmpty
        case .pathNotExistOrIsDirectory(path: let path): return ScriptLocalized.localized_pathNotExistOrIsDirectory(path)
        case .pathPermissionDenied(path: let path): return ScriptLocalized.localized_pathPermissionDenied(path)
        }
    }
}

extension Process.TerminationReason {
    var sc_reason: String {
        switch self {
        case .exit: return ScriptLocalized.localized_processReasonExit
        case .uncaughtSignal: return ScriptLocalized.localized_processReasonUncaughtSignal
        default: return ScriptLocalized.localized_unknownReason(rawValue)
        }
    }
}
