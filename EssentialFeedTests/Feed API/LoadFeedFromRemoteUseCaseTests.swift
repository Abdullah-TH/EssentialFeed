//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Abdullah Althobetey on 07/08/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadFeedFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotRequestData() {
        let url = URL(string: "https://a-url.com")!
        let (_, client) = makeSUT(url: url)
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load() {_  in }
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        sut.load() { _ in }
        sut.load() { _ in }
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (remoteFeedLoader, client) = makeSUT(url: URL(string: "http://a.url.com")!)
        expect(remoteFeedLoader, toCompleteWith: failure(.connectivityError), when: {
            let clientError = NSError(domain: "test", code: 0)
            client.complete(with: clientError)
        })
    }
    
    func test_load_deliversErrorOnNon200() {
        let (remoteFeedLoader, client) = makeSUT(url: URL(string: "http://a.url.com")!)
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach() { index, code in
            expect(remoteFeedLoader, toCompleteWith: failure(.invalidData), when: {
                let json = makeItemsJson(items: [])
                client.complete(with: code, data: json, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200ResponseWithInvalidJSON() {
        let (remoteFeedLoader, client) = makeSUT(url: URL(string: "http://a-url.com")!)
        expect(remoteFeedLoader, toCompleteWith: failure(.invalidData), when: {
                let invalidJSON = Data("invalid JSON".utf8)
                client.complete(with: 200, data: invalidJSON)
        })
    }
    
    func test_load_deliversNoItemsOn200HTTPStatusCodeWithEmptyJSONList() {
        let (remoteFeedLoader, client) = makeSUT(url: URL(string: "http://aurl.com")!)
        expect(remoteFeedLoader, toCompleteWith: .success([]), when: {
            let emptyListJson = makeItemsJson(items: [])
            client.complete(with: 200, data: emptyListJson)
        })
    }
    
    func test_load_deliversItemsOn200HTTPResponseWithValidJSONItems() {
        
        let (remoteFeedLoader, client) = makeSUT(url: URL(string: "http://aurl.com")!)
        
        let item1 = makeImageFeed(id: UUID(),
                             imageURL: URL(string: "http://aurlofimage.com/image.jpg")!)
        
        let item2 = makeImageFeed(id: UUID(),
                             description: "some description",
                             location: "some location",
                             imageURL: URL(string: "http://anotherimage.com/image.png")!)
        
        
        let items = [item1.model, item2.model]
        
        expect(remoteFeedLoader, toCompleteWith: .success(items), when: {
            let itemsJSONData = makeItemsJson(items: [item1.json, item2.json])
            client.complete(with: 200, data: itemsJSONData)
        })
    }
    
    func test_load_doesNotDeliverResultAfterLoaderInstanceHasBeenDeallocated() {
        let client = HTTPClientSpy()
        let url = URL(string: "http://aurl.com")!
        var remoteFeedLoader: RemoteFeedLoader? = RemoteFeedLoader(client: client, url: url)
        
        var capturedResults = [RemoteFeedLoader.Result]()
        remoteFeedLoader?.load() { result in
            capturedResults.append(result)
        }
        remoteFeedLoader = nil
        client.complete(with: 200, data: makeItemsJson(items: []))
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
    
    // MARK: - Helpers
    
    private class HTTPClientSpy: HTTPClient {
        
        private var messages = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with statusCode: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: statusCode,
                                           httpVersion: nil,
                                           headerFields: nil)!
            messages[index].completion(.success((data, response)))
        }
    }
    
    private func expect(
        _ remoteFeedLoader: RemoteFeedLoader,
        toCompleteWith expectedResult: RemoteFeedLoader.Result,
        when action: () -> Void,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let exp = expectation(description: "Wait for load to finish")
        remoteFeedLoader.load() { recievedResult in
            
            switch (recievedResult, expectedResult) {
            case let (.success(receivedItems), .success(expectedItems)):
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case let (.failure(receivedError as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result\(expectedResult) but got \(recievedResult) instead.", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(url: URL) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(client: client, url: url)
        trackForMemoryLeaks(instance: sut)
        trackForMemoryLeaks(instance: client)
        return (sut, client)
    }
    
    private func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return .failure(error)
    }
    
    private func makeImageFeed(
        id: UUID,
        description: String? = nil,
        location: String? = nil,
        imageURL: URL
        ) -> (model: FeedImage, json: [String: Any]) {
        
        let item = FeedImage(id: id, description: description, location: location, url: imageURL)
        let itemJSON = [
            "id": id.uuidString,
            "description": description,
            "location": location,
            "image": imageURL.absoluteString
        ].compactMapValues { $0 }
        
        return (item, itemJSON)
    }
    
    private func makeItemsJson(items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
}
