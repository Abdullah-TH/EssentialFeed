//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Abdullah Althobetey on 22/11/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import Foundation

public final class LocalFeedLoader {
    
    private let store: FeedStore
    private let currentDate: Date
    
    public init(store: FeedStore, currentDate: Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func validateCache() {
        store.retrieveCachedFeed { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
            case .success(.some(let cachedFeed)) where !FeedCachePolicy.validate(cachedFeed.timestamp, against: self.currentDate):
                self.store.deleteCachedFeed { _ in }
            default:
                break
            }
        }
    }
}

extension LocalFeedLoader {
    
    public typealias SaveResult = Result<Void, Error>
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] deletionResult in
            guard let self = self else { return }
            switch deletionResult {
            case .success:
                self.cache(feed: feed, with: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func cache(feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed: feed.toLocalFeedImages(), currentDate: self.currentDate) { [weak self] insertionResult in
            guard self != nil else { return }
            completion(insertionResult)
        }
    }
}

extension LocalFeedLoader: FeedLoader {
    
    public typealias LoadResult = FeedLoader.Result
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieveCachedFeed { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(.some(cachedFeed)) where FeedCachePolicy.validate(cachedFeed.timestamp, against: self.currentDate):
                completion(.success(cachedFeed.feed.toFeedImages()))
            case .success:
                completion(.success([]))
            }
        }
    }
}
    
private extension Array where Element == FeedImage {
    func toLocalFeedImages() -> [LocalFeedImage] {
        return self.map {
            LocalFeedImage(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.url
            )
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toFeedImages() -> [FeedImage] {
        return self.map {
            FeedImage(
                id: $0.id,
                description: $0.description,
                location: $0.location,
                url: $0.url
            )
        }
    }
}
