//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Abdullah Althobetey on 07/08/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import Foundation

public class RemoteFeedLoader: FeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    
    public typealias Result = LoadFeedResult
    
    public enum Error: Swift.Error {
        case connectivityError
        case invalidData
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            switch result {
            case let .success(data, response):
                completion(RemoteFeedLoader.map(data: data, response: response))
            case .failure:
                completion(.failure(RemoteFeedLoader.Error.connectivityError))
            }
        }
    }
    
    private static func map(data: Data, response: HTTPURLResponse) -> Result {
        do {
            let remoteFeedItems = try RemoteFeedItemMapper.map(data: data, response: response)
            return .success(remoteFeedItems.toFeedImages())
        } catch {
            return .failure(error)
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toFeedImages() -> [FeedImage] {
        return self.map {
            FeedImage(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.image
            )
        }
    }
}
