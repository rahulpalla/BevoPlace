//
//  WishlistProductCell.swift
//  BevoPlace
//
//  Created by Navita Dhillon on 11/27/23.
//

import Foundation
import UIKit

class WishlistProductCell: UITableViewCell {
    
    @IBOutlet weak var wishProductImage: UIImageView!
    @IBOutlet weak var wishProductTitleLabel: UILabel!
    @IBOutlet weak var wishProductCategoryLabel: UILabel!
    @IBOutlet weak var wishProductPriceLabel: UILabel!
    
    @IBOutlet weak var wishLeaseLengthLabel: UILabel!

    @IBOutlet weak var wishLeaseBuyLabel: UILabel!
    @IBOutlet weak var wishDummyLeaseLengthLabel: UILabel!
}
