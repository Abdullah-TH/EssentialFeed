//
//  FeedViewController+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Abdullah Althobetey on 26/01/2020.
//  Copyright © 2020 AbdullahTH. All rights reserved.
//

import UIKit
import EssentialFeediOS

extension FeedViewController {
    
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    
    @discardableResult
    func simulateFeedImageViewVisible(at index: Int) -> FeedImageCell? {
        return feedImageView(at: index) as? FeedImageCell
    }
    
    @discardableResult
    func simulateFeedImageViewNotVisible(at row: Int) -> FeedImageCell? {
        let view = simulateFeedImageViewVisible(at: row)
        let delegate = tableView.delegate
        let indexPath = IndexPath(row: row, section: feedImageSection)
        delegate?.tableView?(tableView, didEndDisplaying: view!, forRowAt: indexPath)
        return view
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
