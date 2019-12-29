//
//  FeedTableViewController.swift
//  Prototype
//
//  Created by Abdullah Althobetey on 29/12/2019.
//  Copyright © 2019 AbdullahTH. All rights reserved.
//

import UIKit

struct FeedImageViewModel {
    let imageName: String
    let description: String?
    let location: String? 
}

class FeedTableViewController: UITableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "FeedImageCell", for: indexPath)
    }
}
