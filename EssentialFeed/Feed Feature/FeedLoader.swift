//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Abdullah Althobetey on 06/08/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func loadFeed(completion: @escaping (LoadFeedResult) -> Void)
}
