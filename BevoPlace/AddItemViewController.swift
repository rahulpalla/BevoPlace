//
//  AddItemViewController.swift
//  BevoPlace
//
//  Created by Navita Dhillon on 11/1/23.
//

import UIKit

class AddItemViewController: UIViewController {

    @IBOutlet weak var lendSellSegCtrl: UISegmentedControl!
    
    @IBOutlet weak var category: UIButton!
    
    @IBOutlet weak var titleField: UITextField!
    
    
    @IBOutlet weak var descriptionField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func onPostButtonClicked(_ sender: Any) {
//        var newProduct = Product(id: <#T##Int#>, name: titleField.text, description: descriptionField.text, userID: <#T##Int#>, image: <#T##String#>, lease: <#T##Bool#>, price: <#T##Double#>)
    }
    
}
