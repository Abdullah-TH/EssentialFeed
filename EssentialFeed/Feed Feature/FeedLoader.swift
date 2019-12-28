//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Abdullah Althobetey on 06/08/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (Result) -> Void)
}
