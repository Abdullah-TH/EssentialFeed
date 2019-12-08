//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Abdullah Althobetey on 06/08/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
