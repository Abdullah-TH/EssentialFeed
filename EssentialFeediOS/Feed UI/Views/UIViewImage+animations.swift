//
//  UIViewImage+animations.swift
//  EssentialFeediOS
//
//  Created by Abdullah Althobetey on 30/01/2020.
//  Copyright © 2020 AbdullahTH. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func setImageAnimated(_ newImage: UIImage?) {
        image = newImage
        
        guard newImage != nil else { return }
        
        alpha = 0
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
