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
                completion(FeedItemMapper.map(data: data, response: response))
            case .failure:
                completion(.failure(RemoteFeedLoader.Error.connectivityError))
            }
        }
    }
}
