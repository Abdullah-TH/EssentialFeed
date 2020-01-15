//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Abdullah Althobetey on 20/12/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import Foundation

final class FeedCachePolicy {
    
    private static let maxCacheAgeInDays = 7
    
    private init() {}
    
    static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = Calendar(identifier: .gregorian).date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
