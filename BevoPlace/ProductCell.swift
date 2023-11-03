//
//  ProductCell.swift
//  BevoPlace
//
//  Created by Shaz Momin on 11/3/23.
//

import Foundation
import UIKit

class ProductCell: UITableViewCell {
    @IBOutlet weak var ProductImage: UIImageView!
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var productSizeLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var ctaButton: UIButton!
    @IBOutlet weak var leaseLengthLabel: UILabel!
    
    @IBAction func ctaButtonClicked(_ sender: Any) {
    }
}
