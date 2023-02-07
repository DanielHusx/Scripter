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
        /// 开发pods
        public static let lib = PodCommand(rawValue: "lib")
        /// 操作cocoapods缓存
        public static let cache = PodCommand(rawValue: "cache")
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
        public static func sources(_ urls: [String]) -> Self { Self(rawValue: "--sources=\(urls.joined(separator: ","))") }
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

// MARK: `pod list`
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

// MARK: `pod search`
extension Pod.PodCommand {
    /// 下载特定的pod
    public static func `try`(_ nameOrGitUrl: String, options: [ListOption]? = nil) -> Self {
        command("try", options: options)
    }
    
    public struct TryOption: PodOptionProtocol {
        public let rawValue: [AnyParameterLiteral]
        public init(rawValue: [AnyParameterLiteral]) { self.rawValue = rawValue }
        
        /// Git存储库中podspec文件的名称，如果提供的是GitURL，则此选项才有效
        public static func podspec_name(_ name: String) -> Self { Self(rawValue: "--podspec_name=\(name)") }
        /// 不更新仓库
        public static let no_repo_update = Self(rawValue: "--no-repo-update")
        
    }
}

// MARK: `pod spec xxx`
extension Pod.PodCommand {
    /// 管理pod规范
    public static func spec(_ subCmd: SpecCommand) -> Self {
        Self(rawValue: ["spec"] + subCmd.rawValue)
    }
    
    public struct SpecCommand: ParameterOption {
        public let rawValue: [AnyParameterLiteral]
        public init(rawValue: [AnyParameterLiteral]) { self.rawValue = rawValue }
        
        /// 在当前路径下创建podspec
        public static func create(_ nameOrGithubUrl: String, options: [PodOption]? = nil) -> Self {
            common("create", options: options, reserve: nameOrGithubUrl)
        }
        
        /// 查找podspec中名称符合query的内容
        public static func cat(_ query: String, options: [QueryOption]? = nil) -> Self {
            common("cat", options: options, reserve: query)
        }
        
        /// 查找podspec中名称符合query的路径
        public static func which(_ query: String, options: [QueryOption]? = nil) -> Self {
            common("which", options: options, reserve: query)
        }
        
        public struct QueryOption: PodOptionProtocol {
            public let rawValue: [AnyParameterLiteral]
            public init(rawValue: [AnyParameterLiteral]) { self.rawValue = rawValue }
            
            /// 解析query为正则
            public static let regex = Self(rawValue: "--regex")
            /// 展示所有版本
            public static let show_all = Self(rawValue: "--show-all")
            /// 打印特定版本
            public static let version = Self(rawValue: "--version")
        }
        
        /// 打开podspec匹配query的项以编辑
        public static func edit(_ query: String, options: [EditOption]? = nil) -> Self {
            common("edit", options: options, reserve: query)
        }
        
        public struct EditOption: PodOptionProtocol {
            public let rawValue: [AnyParameterLiteral]
            public init(rawValue: [AnyParameterLiteral]) { self.rawValue = rawValue }
            
            /// 解析query为正则
            public static let regex = Self(rawValue: "--regex")
            /// 展示所有版本
            public static let show_all = Self(rawValue: "--show-all")
        }
        
        /// 验证 NAME.podspec。 如果提供了 DIRECTORY，它会验证找到的 podspec 文件，包括子文件夹。 如果参数被省略，它默认为当前工作目录。
        public static func lint(_ nameOrDirectoryOrPodspecUrl: String, options: [LintOption]? = nil) -> Self {
            common("lint", options: options, reserve: nameOrDirectoryOrPodspecUrl)
        }
        
        public struct LintOption: PodOptionProtocol {
            public let rawValue: [AnyParameterLiteral]
            public init(rawValue: [AnyParameterLiteral]) { self.rawValue = rawValue }
            
            /// 跳过需要下载和构建规范的检查
            public static let quick = Self(rawValue: "--quick")
            /// 允许展示警告
            public static let allow_warnings = Self(rawValue: "--allow-warnings")
            /// 只校验指定的子仓库
            public static func subspec(_ name: String) -> Self { Self(rawValue: "--subspec=\(name)") }
            /// 忽略校验子规范
            public static let no_subspecs = Self(rawValue: "--no-subspecs")
            /// 完整保留构建目录以供检查
            public static let no_clean = Self(rawValue: "--no-clean")
            /// 出现第一个失败的平台或子规范就停止
            public static let fail_fast = Self(rawValue: "--fail_fast")
            /// 使用静态库安装
            public static let use_libraries = Self(rawValue: "--use-libraries")
            /// 安装过程中使用模块化头
            public static let use_modular_headers = Self(rawValue: "--use-modular-headers")
            /// 安装过程使用静态framework
            public static let use_static_frameworks = Self(rawValue: "--use-static-frameworks")
            /// 从中提取依赖 Pod 的来源（默认为 https://cdn.cocoapods.org/）
            public static func sources(_ urls: [String]) -> Self { Self(rawValue: "--sources=\(urls.joined(separator: ","))") }
            /// 针对特定平台的 lint（默认为 podspec 支持的所有平台）
            public static func platforms(_ values: [String]) -> Self { Self(rawValue: "--platforms=\(values.joined(separator: ","))") }
            /// 跳过仅适用于公共规范的检查
            public static let `private` = Self(rawValue: "--private")
            /// 应该用于 lint 规范的 SWIFT_VERSION。 这优先于规范或 .swift-version 文件指定的 Swift 版本。
            public static func swift_version(_ value: String) -> Self { Self(rawValue: "--swift-version=\(value)") }
            /// 跳过验证 pod 是否可以导入。
            public static let skip_import_validation = Self(rawValue: "--skip-import-validation")
            /// Lint 在验证期间跳过构建和运行测试。
            public static let skip_tests = Self(rawValue: "--skip-tests")
            /// 要运行的测试仓库列表。
            public static func test_specs(_ values: [String]) -> Self { Self(rawValue: "--test-specs=\(values.joined(separator: ","))") }
            /// 使用 Xcode 静态分析工具进行验证。
            public static let analyze = Self(rawValue: "--analyze")
            /// 使用给定的配置构建（默认为 Release）。
            public static func configuration(_ name: String) -> Self { Self(rawValue: "--configuration=\(name)") }
        }
    }
}

// MARK: `pod repo xxx`
extension Pod.PodCommand {
    public static func repo(_ subCmd: RepoCommand) -> Self {
        Self(rawValue: ["repo"] + subCmd.rawValue)
    }
    
    public static func setup(_ options: [PodOption]? = nil) -> Self {
        command("setup", options: options)
    }
    
    public struct RepoCommand: ParameterOption {
        public let rawValue: [AnyParameterLiteral]
        public init(rawValue: [AnyParameterLiteral]) { self.rawValue = rawValue }
        
        public static func update(_ name: String? = nil, options: [PodOption]? = nil) -> Self {
            common("update", options: options, reserve: name)
        }
        
        public static func add(_ name: String, url: String, branch: String? = nil, options: [AddOption]? = nil) -> Self {
            var reserve = [name, url]
            if let branch = branch { reserve.append(branch) }
            return common("add", options: options, reserve: reserve, before: true)
        }
        
        public struct AddOption: PodOptionProtocol {
            public let rawValue: [AnyParameterLiteral]
            public init(rawValue: [AnyParameterLiteral]) { self.rawValue = rawValue }
            
            public static let progress = Self(rawValue: "--progress")
        }
        
        public static func add_cdn(_ name: String, url: String, options: [PodOption]? = nil) -> Self {
            common("add-cdn", options: options, reserve: name)
        }
        
        public static func lint(_ nameOrDirectory: String? = nil, options: [LintOption]? = nil) -> Self {
           common("lint", options: options, reserve: nameOrDirectory)
        }
        
        public struct LintOption: PodOptionProtocol {
            public let rawValue: [AnyParameterLiteral]
            public init(rawValue: [AnyParameterLiteral]) { self.rawValue = rawValue }
            
            public static let only_errors = Self(rawValue: "--only-errors")
        }
        
        public static func list(_ options: [ListOption]? = nil) -> Self {
           common("list", options: options)
        }
        
        public struct ListOption: PodOptionProtocol {
            public let rawValue: [AnyParameterLiteral]
            public init(rawValue: [AnyParameterLiteral]) { self.rawValue = rawValue }
            
            public static let count_only = Self(rawValue: "--count-only")
        }
        
        public static func remove(_ name: String, options: [PodOption]? = nil) -> Self {
            common("remove", options: options, reserve: name)
        }
        
        public static func push(_ repo: String, podspec: String? = nil, options: [PushOption]? = nil) -> Self {
           common("push", options: options)
        }
        
        public struct PushOption: PodOptionProtocol {
            public let rawValue: [AnyParameterLiteral]
            public init(rawValue: [AnyParameterLiteral]) { self.rawValue = rawValue }
            
            /// 允许展示警告
            public static let allow_warnings = Self(rawValue: "--allow-warnings")
            /// 使用静态库安装
            public static let use_libraries = Self(rawValue: "--use-libraries")
            /// 安装过程中使用模块化头
            public static let use_modular_headers = Self(rawValue: "--use-modular-headers")
            /// 从中提取依赖 Pod 的来源（默认为 https://cdn.cocoapods.org/）
            public static func sources(_ urls: [String]) -> Self { Self(rawValue: "--sources=\(urls.joined(separator: ","))") }
            /// 不执行将 REPO 推送到其远程的步骤。
            public static let local_only = Self(rawValue: "--local-only")
            /// Lint 包括仅适用于公共存储库的检查。
            public static let no_private = Self(rawValue: "--no-private")
            /// 跳过验证 pod 是否可以导入。
            public static let skip_import_validation = Self(rawValue: "--skip-import-validation")
            /// Lint 在验证期间跳过构建和运行测试。
            public static let skip_tests = Self(rawValue: "--skip-tests")
            /// 应该用于 lint 规范的 SWIFT_VERSION。 这优先于规范或 .swift-version 文件指定的 Swift 版本。
            public static func swift_version(_ value: String) -> Self { Self(rawValue: "--swift-version=\(value)") }
            
            
            /// 只校验指定的子仓库
            public static func commit_message(_ message: String) -> Self { Self(rawValue: "--commit-message=\"\(message)\"") }
            /// 完整保留构建目录以供检查
            public static let no_clean = Self(rawValue: "--no-clean")
            /// 出现第一个失败的平台或子规范就停止
            public static let fail_fast = Self(rawValue: "--fail_fast")
            /// 出现第一个失败的平台或子规范就停止
            public static let fail_fast = Self(rawValue: "--fail_fast")
            /*

             --commit-message="Fix bug in pod"

             Add custom commit message. Opens default editor if no commit message is specified.

             --use-json

             Convert the podspec to JSON before pushing it to the repo.


             --no-overwrite

             Disallow pushing that would overwrite an existing spec.

             --update-sources

             Make sure sources are up-to-date before a push.
             */
        }
    }
}
