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
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

final class FeedPresenter {
            
    private let feedLoadingView: FeedLoadingView
    private let feedView: FeedView
    
    init(feedLoadingView: FeedLoadingView, feedView: FeedView) {
        self.feedLoadingView = feedLoadingView
        self.feedView = feedView
    }
    
    func didStartLoadingFeed() {
        feedLoadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingWith(feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingWith(error: Error) {
        feedLoadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
