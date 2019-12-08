//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Abdullah Althobetey on 22/09/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}

final class RemoteFeedItemMapper {
    
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    private static let http200StatusCode = 200
    
    static func map(data: Data, response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        
        guard
            response.statusCode == http200StatusCode,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
                throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
