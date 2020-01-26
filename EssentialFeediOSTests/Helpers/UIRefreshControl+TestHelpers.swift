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
