//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Abdullah Althobetey on 22/11/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case failure(Error)
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
}

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    typealias RetrievalCompletion = (RetrieveCachedFeedResult) -> Void
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    func insert(feed: [LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion)
    func retrieveCachedFeed(completion: @escaping RetrievalCompletion)
}
