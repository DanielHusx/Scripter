//
//  Pod.swift
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

/// Cocoapods第三方依赖库管理工具
public struct Pod: Script {
    public var path: String?
    public var arguments: [String]?
    public var type: ScriptType
    
    public init(path: String?, arguments: [String]?, type: ScriptType) {
        self.path = path
        self.arguments = arguments
        self.type = type
    }
    
    /// 构建`pod`基础脚本命令
    ///
    /// Cocoapods第三方依赖库管理工具
    /// - Returns: Script
    public init(_ type: ScriptType = .generalApple) {
        self.init(.pod, type: type)
    }
    
    /// pod构建通用命令
    /// - Parameters:
    ///   - command: PodCommand
    ///   - options: PodOptions
    ///   - reserve: 保留参数
    /// - Returns: Script
    public func command(
        commands: [PodCommand],
        reserve: [String]? = nil
    ) -> Self {
        var arguments = self.arguments ?? []
        
        arguments.append(contentsOf: commands.map { $0.rawValue.strings(type) }.flatMap({ $0 }))
        if let reserve = reserve { arguments.append(contentsOf: reserve) }
        
        return duplicate(arguments)
    }
}

extension Pod {
    /// pod指令
    public struct PodCommand {
        public let rawValue: [AnyParameterLiteral]
        public init(rawValue: AnyParameterLiteral...) { self.rawValue = rawValue }
        public init(rawValue: [AnyParameterLiteral]) { self.rawValue = rawValue }
        
        private static func command<T>(
            _ cmd: String,
            options: [T]? = nil,
            reserve: [String]? = nil
        ) -> Self where T: PodOptionProtocol {
            var ret: [AnyParameterLiteral] = [cmd]
            
            if let options = options, !options.isEmpty { ret.append(contentsOf: options.compactMap({ $0.rawValue }).flatMap({ $0 })) }
            if let reserve = reserve, !reserve.isEmpty { ret.append(contentsOf: reserve) }
            
            return Self(rawValue: ret)
        }
        
        private static func command<T>(
            _ cmd: String,
            options: [T]? = nil,
            reserve: String?
        ) -> Self where T: PodOptionProtocol {
            guard let reserve = reserve else { return command(cmd, options: options) }
            return command(cmd, options: options, reserve: [reserve])
        }
        
        /// 当前文档路径下创建Podfile
        public static func initial(_ xcodeproj: String?, options: [PodOption]? = nil) -> Self {
            command("init", options: options, reserve: xcodeproj)
        }
        /// 显示cocoapods环境配置
        public static func environment(_ options: [PodOption]? = nil) -> Self { command("env", options: options) }
        
        /// 展示可用的cocoapods配置
        public static let plugins = PodCommand(rawValue: "plugins")
        /// 设置cocoapods环境
        public static let setup = PodCommand(rawValue: "setup")
        /// 管理pod仓库
        public static let spec = PodCommand(rawValue: "spec")
        /// 开发pods
        public static let lib = PodCommand(rawValue: "lib")
        /// 操作cocoapods缓存
        public static let cache = PodCommand(rawValue: "cache")
        /// 尝试pod项目依赖
        public static let `try` = PodCommand(rawValue: "try")
    }
    
    /// pod选项
    /// - attention: 针对不同command可选项不一样、参照具体命令
    public struct PodOptions {
        public let rawValue: AnyParameterLiteral
        public init(rawValue: AnyParameterLiteral) { self.rawValue = rawValue }
        
        /// 不显示输出
        public static let silent = PodOptions(rawValue: "--silent")
        /// 更新仓库
        public static let repoUpdate = PodOptions(rawValue: "--repo-update")
        /// 详细输出
        public static let verbose = PodOptions(rawValue: "--verbose")
        /// 忽略项目缓存，专注pod安装（只限于项目允许增量安装的情况下使用）
        public static let cleanInstall = PodOptions(rawValue: "--clean-install")
        
        /// 项目文档路径
        public static func projectDirectory(_ directory: String) -> Self {
            PodOptions(rawValue: PathLiteral.part(part: "--project-directory=", path: directory))
        }
        
    }
       
}

public protocol PodOptionProtocol: ParameterOption {}

extension PodOptionProtocol {
    /// 允许`sudo pod`
    public static var allow_root: Self { Self(rawValue: "--allow-root") }
    /// 静默输出
    public static var silent: Self { Self(rawValue: "--silent") }
    /// 工具版本
    public static var version: Self { Self(rawValue: "--version") }
    /// 详细输出
    public static var verbose: Self { Self(rawValue: "--verbose") }
    /// 屏蔽`ANSI codes`输出
    public static var no_ansi: Self { Self(rawValue: "--no-ansi") }
    /// 帮助信息
    public static var help: Self { Self(rawValue: "--help") }
}

extension Pod.PodCommand {
    public struct PodOption: PodOptionProtocol {
        public let rawValue: [AnyParameterLiteral]
        public init(rawValue: [AnyParameterLiteral]) { self.rawValue = rawValue }
    }
}

// MARK: - `pod install`
extension Pod.PodCommand {
    /// 通过Podfile.lock的版本信息安装项目依赖
    public static func install(_ options: [InstallOption]? = nil) -> Self {
        command("install", options: options)
    }
    
    public struct InstallOption: PodOptionProtocol {
        public let rawValue: [AnyParameterLiteral]
        public init(rawValue: [AnyParameterLiteral]) { self.rawValue = rawValue }
        
        /// 更新仓库
        public static let repo_update = Self(rawValue: "--repo-update")
        /// 忽略项目缓存，专注pod安装（只限于项目允许增量安装的情况下使用）
        public static let clean_install = Self(rawValue: "--clean-install")
        /// 安装时禁止`Podfile, Podfile.lock`变更
        public static let deployment = Self(rawValue: "--deployment")
        /// 项目文档路径
        public static func project_directory(_ directory: String) -> Self {
            Self(rawValue: PathLiteral.part(part: "--project-directory=", path: directory))
        }
    }
}

// MARK: - `pod update`
extension Pod.PodCommand {
    /// 更新已过期的项目依赖并创建新的Podfile.lock
    public static func update(_ podNames: [String]? = nil, options: [UpdateOption]? = nil) -> Self {
        command("update", options: options, reserve: podNames)
    }
    
    public struct UpdateOption: PodOptionProtocol {
        public let rawValue: [AnyParameterLiteral]
        public init(rawValue: [AnyParameterLiteral]) { self.rawValue = rawValue }
        
        /// 资源设置
        public static func source(_ value: String) -> Self { Self(rawValue: "--sources=\(value)") }
        /// 不包含某个Pod
        public static func exclude_pods(_ podName: String) -> Self { Self(rawValue: "--exclude-pods=\(podName)") }
        /// 忽略项目缓存，专注pod安装（只限于项目允许增量安装的情况下使用）
        public static let clean_install = Self(rawValue: "--clean-install")
        /// 不更新仓库
        public static let no_repo_update = Self(rawValue: "--no-repo-update")
        /// 项目文档路径
        public static func project_directory(_ directory: String) -> Self {
            Self(rawValue: PathLiteral.part(part: "--project-directory=", path: directory))
        }
    }
}

// MARK: - `pod outdated`
extension Pod.PodCommand {
    /// 展示已过期的项目依赖
    public static func outdated(_ options: [OutdatedOption]? = nil) -> Self {
        command("outdated", options: options)
    }
    
    public struct OutdatedOption: PodOptionProtocol {
        public let rawValue: [AnyParameterLiteral]
        public init(rawValue: [AnyParameterLiteral]) { self.rawValue = rawValue }
        
        /// 忽略预发布
        public static let ignore_prerelease = Self(rawValue: "--ignore-prerelease")
        /// 不更新仓库
        public static let no_repo_update = Self(rawValue: "--no-repo-update")
        /// 项目文档路径
        public static func project_directory(_ directory: String) -> Self {
            Self(rawValue: PathLiteral.part(part: "--project-directory=", path: directory))
        }
        
    }
}

// MARK: `pod deintegrate`
extension Pod.PodCommand {
    /// 从项目中分解cocoapods
    public static func deintegrate(_ options: [DeintegrateOption]? = nil) -> Self {
        command("deintegrate", options: options)
    }
    
    public struct DeintegrateOption: PodOptionProtocol {
        public let rawValue: [AnyParameterLiteral]
        public init(rawValue: [AnyParameterLiteral]) { self.rawValue = rawValue }
        
        /// 指定.xcodeproj文件
        public static func xcodeproj(_ path: String) -> Self { Self(rawValue: [PathLiteral.path(path)]) }
        /// 项目文档路径
        public static func project_directory(_ directory: String) -> Self {
            Self(rawValue: PathLiteral.part(part: "--project-directory=", path: directory))
        }
    }
}

// MARK: `pod search`
extension Pod.PodCommand {
    /// 搜索pods
    public static func search(_ query: String, options: [SearchOption]? = nil) -> Self {
        command("search", options: options, reserve: [query])
    }
    
    public struct SearchOption: PodOptionProtocol {
        public let rawValue: [AnyParameterLiteral]
        public init(rawValue: [AnyParameterLiteral]) { self.rawValue = rawValue }
        
        /// 解析`query`为正则
        public static let regex = Self(rawValue: "--regex")
        /// 只搜索名称
        public static let simple = Self(rawValue: "--simple")
        /// 显示其他统计信息（如 GitHub 观察者和分叉）
        public static let stats = Self(rawValue: "--stats")
        /// 从`cocoapods.org`搜索
        public static let web = Self(rawValue: "--web")
        /// 将搜索限制为支持iOS的 Pod
        public static let ios = Self(rawValue: "--ios")
        /// 将搜索限制为支持osx的 Pod
        public static let osx = Self(rawValue: "--osx")
        /// 将搜索限制为支持watchos的 Pod
        public static let watchos = Self(rawValue: "--watchos")
        /// 将搜索限制为支持tvos的 Pod
        public static let tvos = Self(rawValue: "--tvos")
        /// 不以页展示搜索结果
        public static let no_pager = Self(rawValue: "--no-pager")
    }
}

// MARK: `pod search`
extension Pod.PodCommand {
    /// 展示所有可用的pod
    public static func list(_ options: [ListOption]? = nil) -> Self {
        command("list", options: options)
    }
    
    public struct ListOption: PodOptionProtocol {
        public let rawValue: [AnyParameterLiteral]
        public init(rawValue: [AnyParameterLiteral]) { self.rawValue = rawValue }
        
        public static let update = Self(rawValue: "--update")
        /// 显示其他统计信息（如 GitHub 观察者和分叉）
        public static let stats = Self(rawValue: "--stats")
        
    }
}
