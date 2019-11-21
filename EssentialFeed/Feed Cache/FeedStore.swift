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
    func insert(_ items: [FeedItem], currentDate: Date, completion: @escaping CompletionWithError)
}
