//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Abdullah Althobetey on 29/01/2020.
//  Copyright © 2020 AbdullahTH. All rights reserved.
//

import Foundation
import EssentialFeed

protocol FeedLoadingView {
    func display(isLoading: Bool)
}

protocol FeedView {
    func display(feed: [FeedImage])
}

final class FeedPresenter {
        
    let feedLoader: FeedLoader
    
    var feedLoadingView: FeedLoadingView?
    var feedView: FeedView?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        feedLoadingView?.display(isLoading: true)
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(feed: feed)
            }
            self?.feedLoadingView?.display(isLoading: false)
        }
    }
}
