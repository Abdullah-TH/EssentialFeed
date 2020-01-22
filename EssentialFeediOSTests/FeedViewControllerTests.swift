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
        
        private(set) var loadedImageURLs = [URL]()
        private(set) var cancelledImageURLs = [URL]()
        
        func loadImageData(from url: URL) -> FeedImageDataLoaderTask {
            loadedImageURLs.append(url)
            return Task { [weak self] in
                self?.cancelledImageURLs.append(url)
            }
        }
    }
}

private extension FeedViewController {
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> UITableViewCell? {
        return feedImageView(at: index)
    }
    
    func simulateFeedImageViewNotVisible(at row: Int) {
        let view = simulateFeedImageViewVisible(at: row)
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
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
    
    var locationText: String? {
        return locationLabel.text
    }
    
    var descriptionText: String? {
        return descriptionLabel.text
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
