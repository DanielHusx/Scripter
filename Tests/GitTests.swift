import XCTest
@testable import Scripter

final class GitTests: XCTestCase {
    let directory: String = "/Users/daniel/Documents/iProjects/iGithub/Scripter"
    
    func testVersion() throws {
        let ret = Git().command(options: [.version])
                       .execute()
                       .string
        XCTAssertNotNil(ret, "git版本为空")
    }
    
    func testClone() async throws {
        let repo = "https://github.com/DanielHusx/Scripter.git"
        let dest = "/Users/daniel/Desktop/ScripterTemp"
        let ret = Git(.generalProcess(ignore: true))
                        .command(commands: [.clone(repo, directory: dest)])
                        .execute()
        XCTAssertTrue(ret.isSuccess, "git克隆失败: \(ret.failure!)")
    }
    
    func testCurrentBranch() throws {
        let ret = Git().command(options: [.gitDirectory(directory)],
                                commands: [.branch([.show_current])])
                       .execute()
        print(ret)
        XCTAssertNotNil(ret.string, "git获取当前版本失败：\(ret.failure!)")
    }
    
    func testBranchList() throws {
        let ret = Git().command(options: [.gitDirectory(directory)],
                                commands: [.branch([.all])])
                       .execute()
        print(ret)
        XCTAssertNotNil(ret.string, "git获取版本列表失败：\(ret.failure!)")
    }
}
