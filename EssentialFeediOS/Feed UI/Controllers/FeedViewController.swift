//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Abdullah Althobetey on 16/01/2020.
//  Copyright © 2020 AbdullahTH. All rights reserved.
//

import UIKit

public class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    
    private let refreshController: FeedRefreshViewController
    
    var cellControllers = [FeedImageCellController]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(refreshController: FeedRefreshViewController) {
        self.refreshController = refreshController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupRefreshController()
    }
    
    private func setupTableView() {
        tableView.prefetchDataSource = self
        tableView.register(UINib(nibName: "FeedImageCell", bundle: nil), forCellReuseIdentifier: "FeedImageCell")
    }
    
    private func setupRefreshController() {
        refreshControl = refreshController.refreshControl
        refreshController.refresh()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellControllers.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).cellView(in: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cancelCellControllerLoad(forRowAt: indexPath)
        }
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return cellControllers[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}
