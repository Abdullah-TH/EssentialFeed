//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Abdullah Althobetey on 16/01/2020.
//  Copyright © 2020 AbdullahTH. All rights reserved.
//

import UIKit
import EssentialFeed

public class FeedViewController: UITableViewController {
    
    private var loader: FeedLoader?
    
    public convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        
        load()
    }
    
    @objc private func load() {
        refreshControl?.beginRefreshing()
        loader?.load { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}
