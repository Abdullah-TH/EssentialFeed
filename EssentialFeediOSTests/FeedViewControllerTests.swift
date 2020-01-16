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
            loader.loadCallCount,
            0,
            "Expected no loading requests before view is loaded"
        )
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(
            loader.loadCallCount,
            1,
            "Expected a loading request once the view is loaded"
        )
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(
            loader.loadCallCount,
            2,
            "Expected another loading request once user initiated a load"
        )
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(
            loader.loadCallCount,
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
        
        loader.completeFeedLoading(at: 0)
        XCTAssertFalse(
            sut.isShowingLoadingIndicator,
            "Expected to hide loading indicator once the loading is completed"
        )
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(
            sut.isShowingLoadingIndicator,
            "Expected to show loading indicator once the user initiates a reload"
        )
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeFeedLoading(at: 1)
        XCTAssertFalse(
            sut.isShowingLoadingIndicator,
            "Expected to hide loading indicator once user initiated loading completed"
        )
    }
    
    // MARK: - Helper
    
    private func makeSUT(
        file: StaticString = #file,
        line: uint = #line
    ) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(instance: loader)
        trackForMemoryLeaks(instance: sut)
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        private var completions = [(FeedLoader.Result) -> Void]()
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(at index: Int) {
            completions[index](.success([]))
        }
    }
}

private extension FeedViewController {
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        refreshControl?.isRefreshing ?? false
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
