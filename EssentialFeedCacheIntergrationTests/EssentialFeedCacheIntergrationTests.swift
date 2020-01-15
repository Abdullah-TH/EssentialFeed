//
//  EssentialFeedCacheIntergrationTests.swift
//  EssentialFeedCacheIntergrationTests
//
//  Created by Abdullah Althobetey on 27/12/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import XCTest
import EssentialFeed

class EssentialFeedCacheIntergrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        deleteStoreArtifacts()
    }
    
    override func tearDown() {
        super.tearDown()
        deleteStoreArtifacts()
    }

    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toLoad: [])
    }
    
    func test_load_deliversItemsSavedOnASeparateInstance() {
        let sutToPerformSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().imageFeed
        
        expect(sutToPerformSave, toSave: feed)
        expect(sutToPerformLoad, toLoad: feed)
    }
    
    func test_save_overrideItemsSavedOnASeparateInstance() {
        let sutToPerformFistSave = makeSUT()
        let sutToPerformSecondSave = makeSUT()
        let sutToPerformLoad = makeSUT()
        let feed = uniqueImageFeed().imageFeed
        let latestFeed = uniqueImageFeed().imageFeed
        
        expect(sutToPerformFistSave, toSave: feed)
        expect(sutToPerformSecondSave, toSave: latestFeed)
        expect(sutToPerformLoad, toLoad: latestFeed)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL()
        let store = CodableFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date())
        trackForMemoryLeaks(instance: store, file: file, line: line)
        trackForMemoryLeaks(instance: sut, file: file, line: line)
        return sut
    }
    
    private func expect(
        _ sut: LocalFeedLoader,
        toLoad expectedFeed: [FeedImage],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { result in
            switch result {
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, expectedFeed, "Expected empty feed", file: file, line: line)
            case let .failure(error):
                XCTFail("Expected sucessful feed result, got \(error) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(
        _ sut: LocalFeedLoader,
        toSave feed: [FeedImage],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let saveExp = expectation(description: "Wait for save completion")
        sut.save(feed) { saveResult in
            switch saveResult {
            case .success:
                break
            case .failure(let error):
                XCTFail("Expected to save feed successfully, got \(error) instead")
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

}
