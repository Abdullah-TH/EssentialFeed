//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Abdullah Althobetey on 26/01/2020.
//  Copyright © 2020 AbdullahTH. All rights reserved.
//

import UIKit

final class FeedImageCellController {
    
    private let viewModel: FeedImageViewModel<UIImage>
    
    init(viewModel: FeedImageViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func cellView() -> UITableViewCell {
        let cell = binded(FeedImageCell())
        viewModel.loadImageData()
        return cell
    }
    
    func preload() {
        viewModel.loadImageData()
    }
    
    func cancelLoad() {
        viewModel.cancelImageDataLoad()
    }
    
    private func binded(_ cell: FeedImageCell) -> FeedImageCell {
         cell.locationContainer.isHidden = !viewModel.hasLocation
         cell.locationLabel.text = viewModel.location
         cell.descriptionLabel.text = viewModel.description
         cell.onRetry = viewModel.loadImageData

         viewModel.onImageLoad = { [weak cell] image in
             cell?.feedImageView.image = image
         }

         viewModel.onImageLoadingStateChange = { [weak cell] isLoading in
             cell?.feedImageContainer.isShimmering = isLoading
         }

         viewModel.onShouldRetryImageLoadStateChange = { [weak cell] shouldRetry in
             cell?.feedImageRetryButton.isHidden = !shouldRetry
         }

         return cell
     }
}
