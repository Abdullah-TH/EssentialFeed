//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Abdullah Althobetey on 22/11/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import Foundation

public typealias CachedFeed = (feed: [LocalFeedImage], timestamp: Date)

public protocol FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    
    typealias InsertionCompletion = (Error?) -> Void
    
    typealias RetrieveResult = Result<CachedFeed?, Error>
    typealias RetrievalCompletion = (RetrieveResult) -> Void
    
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
