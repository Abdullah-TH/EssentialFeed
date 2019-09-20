//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Abdullah Althobetey on 07/08/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import Foundation

public class RemoteFeedLoader {
    
    private let client: HTTPClient
    private let url: URL
    
    public enum Result: Equatable {
        case success([FeedItem])
        case failure(Error)
    }
    
    public enum Error: Swift.Error {
        case connectivityError
        case invalidData
    }
    
    private struct Root: Decodable {
        let items: [FeedItem]
    }
    
    public init(client: HTTPClient, url: URL) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(url: url) { result in
            switch result {
            case let .success(data, _):
                if let root = try? JSONDecoder().decode(Root.self, from: data) {
                    completion(.success(root.items))
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure:
                completion(.failure(.connectivityError))
            }
        }
    }
}


