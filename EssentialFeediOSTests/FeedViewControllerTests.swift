//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Abdullah Althobetey on 15/01/2020.
//  Copyright © 2020 AbdullahTH. All rights reserved.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

class FeedViewControllerTests: XCTestCase {
    
    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        XCTAssertEqual(
            loader.feedLoadCallCount,
            0,
            "Expected no loading requests before view is loaded"
        )
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(
            loader.feedLoadCallCount,
            1,
            "Expected a loading request once the view is loaded"
        )
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(
            loader.feedLoadCallCount,
            2,
            "Expected another loading request once user initiated a load"
        )
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(
            loader.feedLoadCallCount,
            3,
            "Expected a third loading request once user initiated another load"
        )
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(
            sut.isShowingLoadingIndicator,
            "Expected to show loading indicator once the view is loaded"
        )
        
        loader.completeFeedLoading(with: [], at: 0)
        XCTAssertFalse(
            sut.isShowingLoadingIndicator,
            "Expected to hide loading indicator once the loading completes successfully"
        )
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(
            sut.isShowingLoadingIndicator,
            "Expected to show loading indicator once the user initiates a reload"
        )
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        XCTAssertFalse(
            sut.isShowingLoadingIndicator,
            "Expected to hide loading indicator once user initiated loading completes with error"
        )
    }
    
    func test_loadFeedCompletion_rendersSuccessfullyLoadedFeed() {
        let image0 = makeImage(descripiton: "a descripion", location: "a locaion")
        let image1 = makeImage(location: "another location")
        let image2 = makeImage(descripiton: "another description")
        let image3 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews, 0)
        
        loader.completeFeedLoading(with: [image0], at: 0)
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews, 1)
        assertThat(sut, hasViewConfiguredFor: image0, at: 0)
        
        sut.simulateUserInitiatedFeedReload()
        
        loader.completeFeedLoading(with: [image0, image1, image2, image3], at: 1)
        XCTAssertEqual(sut.numberOfRenderedFeedImageViews, 4)
        assertThat(sut, hasViewConfiguredFor: image0, at: 0)
        assertThat(sut, hasViewConfiguredFor: image1, at: 1)
        assertThat(sut, hasViewConfiguredFor: image2, at: 2)
        assertThat(sut, hasViewConfiguredFor: image3, at: 3)
    }
    
    func test_loadFeedCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let image0 = makeImage()
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0], at: 0)
        assertThat(sut, isRendering: [image0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoadingWithError(at: 1)
        assertThat(sut, isRendering: [image0])
    }
    
    func test_feedImageView_loadImageURLWhenVisible() {
        let image0 = makeImage(url: URL(string: "http://a-url.com")!)
        let image1 = makeImage(url: URL(string: "http://b-url.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        XCTAssertEqual(
            loader.loadedImageURLs,
            [],
            "Expected no image URL request until views become visible"
        )
        
        sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(
            loader.loadedImageURLs,
            [image0.url],
            "Expected firt image url request once first view become visible"
        )
        
        sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(
            loader.loadedImageURLs,
            [image0.url, image1.url],
            "Expected second image url request once second view also become visible"
        )
    }
    
    func test_feedImageView_cancelsImageLoadingWhenNotVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://a-url.com")!)
        let image1 = makeImage(url: URL(string: "http://b-url.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(
            loader.cancelledImageURLs,
            [],
            "Expected no cancelled image URL requests until image is not visible"
        )
        
        sut.simulateFeedImageViewNotVisible(at: 0)
        XCTAssertEqual(
            loader.cancelledImageURLs,
            [image0.url],
            "Expected one cancelled image URL request once first image is not visible anymore"
        )
        
        sut.simulateFeedImageViewNotVisible(at: 1)
        XCTAssertEqual(
            loader.cancelledImageURLs,
            [image0.url, image1.url],
            "Expected two cancelled image URL requests second image is also not visible"
        )
    }
    
    func test_feedImageViewLoadingIndicator_isVisibleWhileLoadingImage() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(
            view0?.isShowingImageLoadingIndicator,
            true,
            "Expected loading indicator for first view while loading first image"
        )
        XCTAssertEqual(
            view1?.isShowingImageLoadingIndicator,
            true,
            "Expected loading indicator for second view while loading second image"
        )
        
        loader.completeImageLoading(with: Data(), at: 0)
        XCTAssertEqual(
            view0?.isShowingImageLoadingIndicator,
            false,
            "Expected no loading indicator for first view once first image loading comletes successfully"
        )
        XCTAssertEqual(
            view1?.isShowingImageLoadingIndicator,
            true,
            "Expected no loading indicator state change for the second view once the first image loading completes successfully"
        )
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(
            view0?.isShowingImageLoadingIndicator,
            false,
            "Expected no loading indicator state change for first view once second image loading completes with error"
        )
        XCTAssertEqual(
            view1?.isShowingImageLoadingIndicator,
            false,
            "Expected no loading indicator for second view once second image loading completes with error"
        )
    }
    
    func test_feedImageView_rendersImageLoadedFromURL() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(
            view0?.renderedImage,
            .none,
            "Expected no image for firts view while loading first image"
        )
        XCTAssertEqual(
            view1?.renderedImage,
            .none,
            "Expected no image for second view while loading second image"
        )
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(
            view0?.renderedImage,
            imageData0,
            "Expected image for first view once first image completes loading successfully"
        )
        XCTAssertEqual(
            view1?.renderedImage,
            .none,
            "Expected no image state change for second view once first image completes loading successfully"
        )
        
        let imageData1 = UIImage.make(withColor: .blue).pngData()!
        loader.completeImageLoading(with: imageData1, at: 1)
        XCTAssertEqual(
            view0?.renderedImage,
            imageData0,
            "Expected no image state change for first view once second image loading completes successfully"
        )
        XCTAssertEqual(
            view1?.renderedImage,
            imageData1,
            "Expected image for second view once second image completes loading successfully"
        )
    }
    
    func test_feedImageViewRetryButton_isVisibleOnImageURLLoadError() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage(), makeImage()], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(
            view0?.isShowingRetryAction,
            false,
            "Expected no retry action for first view while loading first image"
        )
        XCTAssertEqual(
            view1?.isShowingRetryAction,
            false,
            "Expected no retry action for second view while loading second image"
        )
        
        let imageData0 = UIImage.make(withColor: .red).pngData()!
        loader.completeImageLoading(with: imageData0, at: 0)
        XCTAssertEqual(
            view0?.isShowingRetryAction,
            false,
            "Expected no retry action for first view once first image loading completes successfully"
        )
        XCTAssertEqual(
            view1?.isShowingRetryAction,
            false,
            "Expected no retry action state change for second view once first image loading completes successfully"
        )
        
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(
            view0?.isShowingRetryAction,
            false,
            "Expected no retry action state change for frist view once second view completes loading successfully"
        )
        XCTAssertEqual(
            view1?.isShowingRetryAction,
            true,
            "Expected retry action for second view once second image loading completes with error"
        )
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [makeImage()], at: 0)
        
        let view = sut.simulateFeedImageViewVisible(at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, false, "Expected no retry action while loading image")
        
        let invalidImageData = Data("Invalid image data".utf8)
        loader.completeImageLoading(with: invalidImageData, at: 0)
        XCTAssertEqual(view?.isShowingRetryAction, true, "Expected retry action visible once loading image completes with invalid image data")
        
    }
    
    func test_feedImageRetryAction_retriesImageLoad() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        
        let view0 = sut.simulateFeedImageViewVisible(at: 0)
        let view1 = sut.simulateFeedImageViewVisible(at: 1)
        XCTAssertEqual(
            loader.loadedImageURLs,
            [image0.url, image1.url],
            "Expected two image url requests for the two visible views"
        )
        
        loader.completeImageLoadingWithError(at: 0)
        loader.completeImageLoadingWithError(at: 1)
        XCTAssertEqual(
            loader.loadedImageURLs,
            [image0.url, image1.url],
            "Expected only two image url requests before the retry action"
        )
        
        view0?.simulateRetryAction()
        XCTAssertEqual(
            loader.loadedImageURLs,
            [image0.url, image1.url, image0.url],
            "Expected third image url request after first view retry action"
        )
        
        view1?.simulateRetryAction()
        XCTAssertEqual(
            loader.loadedImageURLs,
            [image0.url, image1.url, image0.url, image1.url],
            "Expected fourth image url request after second view retry action"
        )
    }
    
    func test_feedImageView_preloadsImageURLWhenNearVisible() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [], "Expected no image url requests until image is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 0)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url], "Expected first image url request once first image is near visible")
        
        sut.simulateFeedImageViewNearVisible(at: 1)
        XCTAssertEqual(loader.loadedImageURLs, [image0.url, image1.url], "Expected both image url requests once second image is near visible")
    }
    
    func test_feedImageView_cancelImageURLPreloadingWhenNotNearVisibleAnymore() {
        let image0 = makeImage(url: URL(string: "http://url-0.com")!)
        let image1 = makeImage(url: URL(string: "http://url-1.com")!)
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.completeFeedLoading(with: [image0, image1], at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [], "Expected no cancelled image url requests until image is not near visible")
        
        sut.simulateFeedImageViewNotNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url], "Expected first cancelled image url request once first image is not near visible anymore")
        
        sut.simulateFeedImageViewNotNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledImageURLs, [image0.url, image1.url], "Expected both image url requests cancelled once second image is not near visible")
    }
    
    // MARK: - Helper
    
    private func makeSUT(
        file: StaticString = #file,
        line: uint = #line
    ) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(feedLoader: loader, imageLoader: loader)
        trackForMemoryLeaks(instance: loader)
        trackForMemoryLeaks(instance: sut)
        return (sut, loader)
    }
    
    private func makeImage(
        descripiton: String? = nil,
        location: String? = nil,
        url: URL = URL(string: "http://any-url.com")!
    ) -> FeedImage {
        return FeedImage(
            id: UUID(),
            description: description,
            location: location,
            url: url
        )
    }
    
    private func assertThat(
        _ sut: FeedViewController,
        isRendering feed: [FeedImage],
        file: StaticString = #file,
        line: UInt = #line
    ) {
        continueAfterFailure = false
        XCTAssertEqual(
            sut.numberOfRenderedFeedImageViews,
            feed.count,
            file: file,
            line: line
        )
        continueAfterFailure = true
        
        feed.enumerated().forEach { index, image in
            assertThat(
                sut,
                hasViewConfiguredFor: image,
                at: index,
                file: file,
                line: line
            )
        }
    }
    
    private func assertThat(
        _ sut: FeedViewController,
        hasViewConfiguredFor image: FeedImage,
        at index: Int,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let view = sut.feedImageView(at: index)
        
        guard let cell = view as? FeedImageCell else {
            XCTFail(
                "Expected \(FeedImageCell.self) instance, got \(String(describing: view)) instead.",
                file: file,
                line: line
            )
            return
        }
        
        let shouldLocationBeVisible = (image.location != nil)
        XCTAssertEqual(
            cell.isShowingLocation,
            shouldLocationBeVisible,
            "Expected `isShowingLocation` to be \(shouldLocationBeVisible) for image view at index \(index)",
            file: file,
            line: line
        )
        
        XCTAssertEqual(
            cell.locationText,
            image.location,
            "Expected location text to be \(String(describing: image.location)) for image view at index \(index)",
            file: file,
            line: line
        )
        
        XCTAssertEqual(
            cell.descriptionText,
            image.description,
            "Expected description text to be \(String(describing: image.description)) for image view at index \(index)",
            file: file,
            line: line
        )
    }
    
    class LoaderSpy: FeedLoader, FeedImageDataLoader {
        
        // MARK: - FeedLoader
        
        private var feedRequests = [(FeedLoader.Result) -> Void]()
        
        var feedLoadCallCount: Int {
            return feedRequests.count
        }
        
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            feedRequests.append(completion)
        }
        
        func completeFeedLoading(with feed: [FeedImage], at index: Int) {
            feedRequests[index](.success(feed))
        }
        
        func completeFeedLoadingWithError(at index: Int) {
            let error = NSError(domain: "any error", code: 0)
            feedRequests[index](.failure(error))
        }
        
        // MARK: - FeedImageDataLoader
        
        private struct Task: FeedImageDataLoaderTask {
            let cancelCallback: () -> Void
            func cancel() {
                cancelCallback()
            }
        }
        
        private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        private(set) var cancelledImageURLs = [URL]()
        
        var loadedImageURLs: [URL] {
            return imageRequests.map { $0.url }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            imageRequests.append((url, completion))
            return Task { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
        
        func completeImageLoading(with data: Data, at index: Int) {
            imageRequests[index].completion(.success(data))
        }
        
        func completeImageLoadingWithError(at index: Int) {
            let error = NSError(domain: "error", code: 0)
            imageRequests[index].completion(.failure(error))
        }
    }
}

private extension FeedViewController {
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    func simulateFeedImageViewNotVisible(at row: Int) {
        let view = simulateFeedImageViewVisible(at: row)
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
    }
    
    func simulateFeedImageViewNearVisible(at row: Int) {
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedImageSection)
        ds?.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulateFeedImageViewNotNearVisible(at row: Int) {
        simulateFeedImageViewNearVisible(at: row)
        let ds = tableView.prefetchDataSource
        let indexPath = IndexPath(row: row, section: feedImageSection)
        ds?.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
    }
    
    var numberOfRenderedFeedImageViews: Int {
        return tableView.numberOfRows(inSection: feedImageSection)
    }
    
    var feedImageSection: Int {
        return 0
    }
    
    func feedImageView(at row: Int) -> UITableViewCell? {
        let dataSource = tableView.dataSource
        let index = IndexPath(row: row, section: feedImageSection)
        return dataSource?.tableView(tableView, cellForRowAt: index)
    }
}

private extension FeedImageCell {
    
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return feedImageContainer.isShimmering
    }
    
    var isShowingRetryAction: Bool {
        return !feedImageRetryButton.isHidden
    }
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
    }
    
    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }
    
    func simulateRetryAction() {
        feedImageRetryButton.simulateTap()
    }
}

private extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        self.allTargets.forEach { target in
            self.actions(
                forTarget: target,
                forControlEvent: .valueChanged
            )?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}

private extension UIButton {
    
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach { action in
                (target as NSObject).perform(Selector(action))
            }
        }
    }
}
