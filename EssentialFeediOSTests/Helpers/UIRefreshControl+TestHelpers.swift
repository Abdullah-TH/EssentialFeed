//
//  UIRefreshControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Abdullah Althobetey on 26/01/2020.
//  Copyright © 2020 AbdullahTH. All rights reserved.
//

import UIKit

extension UIRefreshControl {
    
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
