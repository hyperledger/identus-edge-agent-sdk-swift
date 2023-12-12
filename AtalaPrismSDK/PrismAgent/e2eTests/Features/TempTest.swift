//
//  File.swift
//  
//
//  Created by io on 12/12/23.
//

import Foundation
import XCTest

class TempTest: XCTestCase {
    fileprivate let packageRootPath = URL(fileURLWithPath: #file).pathComponents
        .prefix(while: {
            print($0)
            return $0 != "Tests"
        }).joined(separator: "/").dropFirst()

    func testSomething() {
//        CucumberLogger.writeToGithubSummary("ls -la")
//        CucumberLogger.writeToGithubSummary("pwd")
//        CucumberLogger.writeToGithubSummary("printenv")
        print(packageRootPath)
        
    }
}
