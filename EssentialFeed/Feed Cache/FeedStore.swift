//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Abdullah Althobetey on 22/11/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import Foundation

public protocol FeedStore {
    typealias CompletionWithError = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping CompletionWithError)
    func insert(_ items: [LocalFeedItem], currentDate: Date, completion: @escaping CompletionWithError)
}

public struct LocalFeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
