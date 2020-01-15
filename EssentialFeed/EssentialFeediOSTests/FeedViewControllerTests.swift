//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Abdullah Althobetey on 15/01/2020.
//  Copyright © 2020 AbdullahTH. All rights reserved.
//

import XCTest

class FeedViewController {
    
    init(loader: FeedViewControllerTests.LoaderSpy) {
        
    }
}

class FeedViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    // MARK: - Helper
    
    class LoaderSpy {
        private(set) var loadCallCount = 0
    }
}
