//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Abdullah Althobetey on 26/01/2020.
//  Copyright © 2020 AbdullahTH. All rights reserved.
//

import EssentialFeed

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(
        feedLoader: FeedLoader,
        imageLoader: FeedImageDataLoader
    ) -> FeedViewController {
        
        let refreshController = FeedRefreshViewController(feedLoader: feedLoader)
        let feedViewController = FeedViewController(refreshController: refreshController)
        refreshController.onRefresh = adaptFeedImagesToCellControllers(
            forwardingTo: feedViewController,
            imageLoader: imageLoader
        )
        
        return feedViewController
    }
    
    private static func adaptFeedImagesToCellControllers(
        forwardingTo controller: FeedViewController,
        imageLoader: FeedImageDataLoader
    ) -> (([FeedImage]) -> Void) {
        
        return { [weak controller] feed in
            controller?.cellControllers = feed.map { model in
                FeedImageCellController(model: model, feedImageLoader: imageLoader)
            }
        }
    }
}
