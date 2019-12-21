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
    
    /// The completion handler can be run in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
    
    /// The completion handler can be run in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(feed: [LocalFeedImage], currentDate: Date, completion: @escaping InsertionCompletion)
    
    /// The completion handler can be run in any thread.
    /// Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieveCachedFeed(completion: @escaping RetrievalCompletion)
}
