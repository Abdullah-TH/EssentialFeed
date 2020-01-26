//
//  UIControl+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Abdullah Althobetey on 26/01/2020.
//  Copyright © 2020 AbdullahTH. All rights reserved.
//

import UIKit

extension UIControl {
    
   func simulate(event: UIControl.Event) {
       allTargets.forEach { target in
           actions(forTarget: target, forControlEvent: event)?.forEach {
               (target as NSObject).perform(Selector($0))
           }
       }
   }
}
