//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Abdullah Althobetey on 26/01/2020.
//  Copyright © 2020 AbdullahTH. All rights reserved.
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    
    private init() {}
    
    public static func feedComposedWith(
        feedLoader: FeedLoader,
        imageLoader: FeedImageDataLoader
    ) -> FeedViewController {
        
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedViewController = FeedViewController(refreshController: refreshController)
        feedViewModel.onFeedLoad = adaptFeedImagesToCellControllers(
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
                let viewModel = FeedImageViewModel(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init)
                return FeedImageCellController(viewModel: viewModel)
            }
        }
    }
}
