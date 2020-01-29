//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Abdullah Althobetey on 29/01/2020.
//  Copyright © 2020 AbdullahTH. All rights reserved.
//

import Foundation
import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
        
    let feedLoader: FeedLoader
    
    var feedLoadingView: FeedLoadingView?
    var feedView: FeedView?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func loadFeed() {
        feedLoadingView?.display(FeedLoadingViewModel(isLoading: true))
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(FeedViewModel(feed: feed))
            }
            self?.feedLoadingView?.display(FeedLoadingViewModel(isLoading: false))
        }
    }
}
