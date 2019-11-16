//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Abdullah Althobetey on 22/09/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import Foundation

final class FeedItemMapper {
    
    private struct Root: Decodable {
        let items: [Item]
        
        var feedItems: [FeedItem] {
            return items.map { $0.feedItem }
        }
    }
    
    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var feedItem: FeedItem {
            return FeedItem(
                id: id,
                description: description,
                location: location,
                imageURL: image)
        }
    }
    
    private static let http200StatusCode = 200
    
    static func map(data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        
        guard
            response.statusCode == http200StatusCode,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
                return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feedItems)
    }
}
