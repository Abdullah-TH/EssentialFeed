//
//  UIButton+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Abdullah Althobetey on 26/01/2020.
//  Copyright © 2020 AbdullahTH. All rights reserved.
//

import UIKit

extension UIButton {
    
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
