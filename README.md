# Scripter
封装swift macOS下`Process, NSAppleScript`执行脚本



### 集成

#### Swift Package Manager(SPM)

```swift
dependencies: [
    .package(url: "https://github.com/DanielHusx/Scripter.git", .upToNextMajor(from: "1.0.0"))
]
```



### 使用方法

#### 通用

**支持的脚本：git, pod, ruby, whereis, which, symbolicatecrash**

```swift
import Scripter

let version = Git().command(options: [.version])
               	   .execute()
               	   .string
// version: git version 2.22.0

let whichPath = Whereis().pureScriptPath(commandString)
			 .execute()
			 .string
// whichPath: /usr/bin/which
```

#### 扩展新命令

```swift
import Scripter

// 1. 定义新的的命令类型
extension ScriptCommand {
  // 初始化 路径支持以下几种方式
  // - 默认路径: `Self("echo", path: "echo")`
  // - 脚本或自定义获取（默认方式）: `Self("echo", fetcher: fetchBy(whereis:))`
  public static let echo = Self("echo", path: "echo")
}

// 2. 实现Script协议
public struct Echo: Script {
    public var path: String?
    public var arguments: [String]?
    public var type: ScriptType
    
    public init(path: String?, arguments: [String]?, type: ScriptType) {
        self.path = path
        self.arguments = arguments
        self.type = type
    }
    
    /// echo构建基本命令
    ///
    /// 打印输出信息
    public init(_ type: ScriptType = .generalApple) {
        self.init(.echo, type: type)
    }
    
    public func command(_ value: String) -> Self {
        var arguments = self.arguments ?? []
        arguments.append(value)
        
        return duplicate(arguments)
    }
    
    /// `echo $(other shell command)`
    public func echo_combine<T>(_ other: T) -> Self where T: Script {
        var arguments = self.arguments ?? []
        
        arguments.append("$(\(other.shell))")
        
        return duplicate(arguments)
    }
}

// 3. 执行脚本
let echo_print = Echo().command("123")
		       .execute()
		       .string
// echo_print: 123
```



### Liscense

[MIT License](https://github.com/DanielHusx/Scripter/blob/main/LICENSE)
