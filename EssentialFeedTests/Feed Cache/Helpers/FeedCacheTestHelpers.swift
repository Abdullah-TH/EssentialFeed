//
//  FeedCacheTestHelpers.swift
//  EssentialFeedTests
//
//  Created by Abdullah Althobetey on 18/12/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
    return FeedImage(
        id: UUID(),
        description: nil,
        location: nil,
        url: anyURL()
    )
}

func uniqueImageFeed() -> (imageFeed: [FeedImage], localImageFeed: [LocalFeedImage]) {
    let feed = [uniqueImage(), uniqueImage()]
    let localFeed = feed.map {
        LocalFeedImage(
            id: $0.id,
            description: $0.description,
            location: $0.location,
            url: $0.url
        )
    }
    return (feed, localFeed)
}

extension Date {
    
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return self + seconds
    }
}
