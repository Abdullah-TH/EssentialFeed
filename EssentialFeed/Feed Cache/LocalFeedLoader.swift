//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Abdullah Althobetey on 22/11/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import Foundation

public final class LocalFeedLoader {
    
    public typealias SaveResult = Error?
    
    private let store: FeedStore
    private let currentDate: Date
    
    public init(store: FeedStore, currentDate: Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ feed: [FeedImage], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed: feed, with: completion)
            }
        }
    }
    
    private func cache(feed: [FeedImage], with completion: @escaping (Error?) -> Void) {
        store.insert(feed.toLocalFeedImages(), currentDate: self.currentDate) { [weak self] error in
            guard self != nil else { return }
            completion(error)
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocalFeedImages() -> [LocalFeedImage] {
        return self.map {
            LocalFeedImage(id: $0.id,
                          description: $0.description,
                          location: $0.location,
                          url: $0.url
            )
        }
    }
}
