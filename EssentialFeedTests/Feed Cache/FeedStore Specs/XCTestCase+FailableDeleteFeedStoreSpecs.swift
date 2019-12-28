//
//  XCTestCase+FailableDeleteFeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Abdullah Althobetey on 22/12/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import XCTest
import EssentialFeed

extension FailableDeleteFeedStoreSpecs where Self: XCTestCase {
    
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStore) {
        let deletionError = deleteCache(from: sut)
        XCTAssertNotNil(deletionError, "Expected cache deletion to fail")
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStore) {
        deleteCache(from: sut)
        expect(sut, toRetrieve: .success(.empty))
    }
    
}
