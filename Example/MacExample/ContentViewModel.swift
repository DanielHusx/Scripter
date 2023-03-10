//
//  ContentViewModel.swift
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
import Scripter

class ContentViewModel: ObservableObject {
    private let git_dir = "/Users/iosteam/Desktop/Scripter/.git"//"/Users/daniel/Documents/iProjects/iGithub/Scripter/.git"
    func echo_print() {
        let ret = Echo().command("123")
                        .execute()
                        .string
        print(ret ?? "nil")
    }
    
    func git_currentBranch(_ type: ScriptType) {
        Task {
            let s = CFAbsoluteTimeGetCurrent()
            let ret = Git(type).command(options: [.git_dir(git_dir)],
                                        commands: [.branch([.show_current])])
                .execute()
            let e = CFAbsoluteTimeGetCurrent()
            print("\(e - s)s - \(ret)")
        }
    }
    
    func git_currentBranchByProcess() {
        git_currentBranch(.generalProcess(ignore: false))
    }
    
    func git_currentBranchByApple() {
        git_currentBranch(.generalApple)
    }
}
