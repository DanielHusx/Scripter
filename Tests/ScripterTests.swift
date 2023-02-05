import XCTest
@testable import Scripter

final class ScripterTests: XCTestCase {
    private func common(_ cmd: ScriptCommand, aspect: String) throws {
        let ret = cmd.path ?? "nil"
        XCTAssertEqual(ret, aspect, "\(cmd.rawValue): \(ret) 与期望路径不符: \(aspect)")
    }
    
    private func common(_ cmd: ScriptCommand, contain aspect: String) throws {
        let ret = cmd.path ?? "nil"
        XCTAssertTrue(ret.contains(aspect), "\(cmd.rawValue): \(ret) 不包含期望路径片段: \(aspect)")
    }
}

extension ScripterTests {
    func testGit() throws {
        try common(.git, aspect: "/usr/bin/git")
    }
    
    func testPod() throws {
        try common(.pod, aspect: "/usr/local/bin/pod")
    }
    
    func testRuby() throws {
        try common(.ruby, aspect: "/usr/bin/ruby")
    }
    
    func testWhereis() throws {
        try common(.whereis, aspect: "/usr/bin/whereis")
    }
    
    func testWhich() throws {
        try common(.which, aspect: "/usr/bin/which")
    }
    
    func testSymbolicatedcrash() throws {
        try common(.symbolicatecrash, contain: "Resources/symbolicatecrash")
    }
    
}

