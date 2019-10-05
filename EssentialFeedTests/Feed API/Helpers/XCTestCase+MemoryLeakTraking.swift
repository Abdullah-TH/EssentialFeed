//
//  XCTestCase+MemoryLeakTraking.swift
//  EssentialFeedTests
//
//  Created by Abdullah Althobetey on 06/10/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import XCTest

extension XCTestCase {
    
    func trackForMemoryLeaks(instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
