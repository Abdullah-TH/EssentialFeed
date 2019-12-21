//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Abdullah Althobetey on 21/12/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import XCTest
import EssentialFeed

class CodableFeedStore {
    
    private struct Cache: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map { $0.localFeedImage }
        }
    }
    
    private struct CodableFeedImage: Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ image: LocalFeedImage) {
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var localFeedImage: LocalFeedImage {
            return LocalFeedImage(
                id: id,
                description: description,
                location: location,
                url: url
            )
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(completion: @escaping FeedStore.RetrievalCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            completion(.empty)
            return
        }
        
        do {
            let jsonDecoder = JSONDecoder()
            let cache = try jsonDecoder.decode(Cache.self, from: data)
            completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    func insert(_ feed: [LocalFeedImage], currentDate: Date, completion: @escaping FeedStore.InsertionCompletion) {
        do {
            let encoder = JSONEncoder()
            let codableFeed = feed.map(CodableFeedImage.init)
            let cache = Cache(feed: codableFeed, timestamp: currentDate)
            let encodedData = try! encoder.encode(cache)
            try encodedData.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func delete(completion: @escaping FeedStore.DeletionCompletion) {
        do {
            if FileManager.default.fileExists(atPath: storeURL.path) {
                try FileManager.default.removeItem(at: storeURL)
            }
            completion(nil)
        } catch {
            completion(error)
        }
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        removeArtifacts()
    }
    
    override func tearDown() {
        super.tearDown()
        removeArtifacts()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieveTwice_deliversEmptyOnEmptyCacheWithNoSideEffects() {
        let sut = makeSUT()
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().localImageFeed
        let timestamp = Date()
        
        let insertionError = insert(cache: (feed, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected successful insertion")
        expect(sut, toRetrieve: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().localImageFeed
        let timestamp = Date()
        
        let insertionError = insert(cache: (feed, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected successful insertion")
        expect(sut, toRetrieveTwice: .found(feed: feed, timestamp: timestamp))
    }
    
    func test_retrive_deliversFailureOnRetrivalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrive_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        expect(sut, toRetrieveTwice: .failure(anyNSError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        let feed = uniqueImageFeed()
        let timestamp = Date()
        
        let insertionError = insert(cache: (feed.localImageFeed, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expected successful insertion")
        
        let latestFeed = uniqueImageFeed()
        let latestTimestamp = Date()
        
        let latestInsertionError = insert(cache: (latestFeed.localImageFeed, latestTimestamp), to: sut)
        XCTAssertNil(latestInsertionError, "Expected successful insertion")
        
        expect(sut, toRetrieve: .found(feed: latestFeed.localImageFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed()
        let timestamp = Date()
        
        let exp = expectation(description: "wait for cache insertion")
        sut.insert(feed.localImageFeed, currentDate: timestamp) { insertionError in
            XCTAssertNotNil(insertionError, "Expected cache insertion to fail with an error")
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_delete_hasNoSideEffectOnEmptyCache() {
        let sut = makeSUT()
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected deletion to succeed")
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed()
        let timestamp = Date()
        
        let insertionError = insert(cache: (feed.localImageFeed, timestamp), to: sut)
        XCTAssertNil(insertionError, "Expect insertion to succeed")
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "Expected deletion to succeed")
                
        expect(sut, toRetrieve: .empty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(
        storeURL: URL? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        trackForMemoryLeaks(instance: sut)
        return sut
    }
    
    private func expect(
        _ sut: CodableFeedStore,
        toRetrieve expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for cache retrival")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty), (.failure, .failure):
                break
            case let (.found(expected), .found(retrieved)):
                XCTAssertEqual(expected.feed, retrieved.feed, file: file, line: line)
                XCTAssertEqual(expected.timestamp, retrieved.timestamp, file: file, line: line)
                
            default:
                XCTFail("Expected to recieve \(expectedResult), got \(retrievedResult) instead.", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(
        _ sut: CodableFeedStore,
        toRetrieveTwice expectedResult: RetrieveCachedFeedResult,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    private func insert(
        cache: (feed: [LocalFeedImage], timestamp: Date),
        to sut: CodableFeedStore
    ) -> Error? {
        let exp = expectation(description: "wait for cache insertion")
        var recievedError: Error?
        sut.insert(cache.feed, currentDate: cache.timestamp) { insertionError in
            recievedError = insertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return recievedError
    }
    
    private func deleteCache(from sut: CodableFeedStore) -> Error? {
        let exp = expectation(description: "Wait for cache deletion")
        var recievedError: Error?
        sut.delete { deletionError in
            recievedError = deletionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return recievedError
    }
    
    private func testSpecificStoreURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func removeArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }

}
