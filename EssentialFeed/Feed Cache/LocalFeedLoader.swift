//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Abdullah Althobetey on 22/11/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import Foundation

private final class FeedCachePolicy {
    
    private let currentDate: Date
    private let maxCacheAgeInDays = 7
    
    init(currentDate: Date) {
        self.currentDate = currentDate
    }
    
    func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = Calendar(identifier: .gregorian).date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return currentDate < maxCacheAge
    }
}

public final class LocalFeedLoader {
    
    private let store: FeedStore
    private let cachePolicy: FeedCachePolicy
    private let currentDate: Date
    
    public init(store: FeedStore, currentDate: Date) {
        self.store = store
        self.currentDate = currentDate
        cachePolicy = FeedCachePolicy(currentDate: currentDate)
    }
    
    public func validateCache() {
        store.load { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
            case let .found(_, timestamp) where !self.cachePolicy.validate(timestamp):
                self.store.deleteCachedFeed { _ in }
            default:
                break
            }
        }
    }
}

extension LocalFeedLoader {
    
    public typealias SaveResult = Error?
    
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

extension LocalFeedLoader: FeedLoader {
    
    public typealias LoadResult = LoadFeedResult
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.load { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .found(localFeed, timestamp) where self.cachePolicy.validate(timestamp):
                completion(.success(localFeed.toFeedImages()))
            case .found, .empty:
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
