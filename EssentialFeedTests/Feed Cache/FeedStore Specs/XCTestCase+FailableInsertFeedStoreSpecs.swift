//
//  XCTestCase+FailableInsertFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Abdullah Althobetey on 22/12/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import XCTest
import EssentialFeed

extension FailableInsertFeedStoreSpecs where Self: XCTestCase {

    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStore) {
        let feed = uniqueImageFeed()
        let timestamp = Date()
        
        let insertionError = insert(cache: (feed.localImageFeed, timestamp), to: sut)
        XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
    }
    
    func assertThatInsertHasNoSideEffectOnInsertionError(on sut: FeedStore) {
        let feed = uniqueImageFeed()
        let timestamp = Date()
        
        insert(cache: (feed.localImageFeed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .success(.empty))
    }
    
}
