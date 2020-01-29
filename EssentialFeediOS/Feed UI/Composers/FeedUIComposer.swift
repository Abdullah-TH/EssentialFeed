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
        
        let feedLoaderPresentationAdapter = FeedLoaderPresentationAdapter(
            feedLoader: feedLoader
        )
        
        let refreshController = FeedRefreshViewController(
            delegate: feedLoaderPresentationAdapter
        )
        
        let feedViewController = FeedViewController(refreshController: refreshController)
        
        let feedPresenter = FeedPresenter(
            feedLoadingView: WeakRefrenceVirtualProxy(refreshController),
            feedView: FeedViewAdapter(controller: feedViewController, imageLoader: imageLoader)
        )
        
        feedLoaderPresentationAdapter.presenter = feedPresenter
        
        return feedViewController
    }
}

private final class WeakRefrenceVirtualProxy<T: AnyObject> {
    
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefrenceVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefrenceVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
   func display(_ model: FeedImageViewModel<UIImage>) {
       object?.display(model)
   }
}

private final class FeedViewAdapter: FeedView {
    
    private weak var controller: FeedViewController?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewController, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.cellControllers = viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefrenceVirtualProxy<FeedImageCellController>, UIImage>(model: model, imageLoader: imageLoader)
             let view = FeedImageCellController(delegate: adapter)

             adapter.presenter = FeedImagePresenter(
                 view: WeakRefrenceVirtualProxy(view),
                 imageTransformer: UIImage.init)

             return view
        }
    }
}

private final class FeedLoaderPresentationAdapter: FeedRefreshViewControllerDelegate {
    
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingWith(feed: feed)
            case let .failure(error):
                self?.presenter?.didFinishLoadingWith(error: error)
            }
        }
    }
}

private final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
   private let model: FeedImage
   private let imageLoader: FeedImageDataLoader
   private var task: FeedImageDataLoaderTask?

   var presenter: FeedImagePresenter<View, Image>?

   init(model: FeedImage, imageLoader: FeedImageDataLoader) {
       self.model = model
       self.imageLoader = imageLoader
   }

   func didRequestImage() {
       presenter?.didStartLoadingImageData(for: model)

       let model = self.model
       task = imageLoader.loadImageData(from: model.url) { [weak self] result in
           switch result {
           case let .success(data):
               self?.presenter?.didFinishLoadingImageData(with: data, for: model)

           case let .failure(error):
               self?.presenter?.didFinishLoadingImageData(with: error, for: model)
           }
       }
   }

   func didCancelImageRequest() {
       task?.cancel()
   }
}
