//
//  Extensions.swift
//  BevoPlace
//
//  Created by Shaz Momin on 11/27/23.
//

import Foundation
import SwiftUI

extension UIImage {
    func aspectFittedToHeight(_ newHeight: CGFloat) -> UIImage {
        let scale = newHeight / self.size.height
        let newWidth = self.size.width * scale
        let newSize = CGSize (width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        
        return renderer.image {_ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
                                            
