//
//  AddItemViewController.swift
//  BevoPlace
//
//  Created by Navita Dhillon on 11/1/23.
//

import UIKit

var categoryPickerData = ["Textbooks", "UT Merch", "Stationary", "Electronics", "Travel"]
var sizePickerData = ["n/a", "XS", "S", "M", "L", "XL"]
var periodsPickerData = ["days", "weeks", "months"]

class AddItemViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var lendSellSegCtrl: UISegmentedControl!
    
    @IBOutlet weak var categoryPicker: UIPickerView!
    
    @IBOutlet weak var sizePicker: UIPickerView!
    
    @IBOutlet weak var periodsPicker: UIPickerView!
    
    @IBOutlet weak var periodsLabel: UILabel!
    
    @IBOutlet weak var titleField: UITextField!
    
  
    @IBOutlet weak var priceTextField: UITextField!
    
    @IBOutlet weak var numPeriodsTextField: UITextField!
    @IBOutlet weak var numPeriodsLabel: UILabel!
    
    @IBOutlet weak var descriptionField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        sizePicker.delegate = self
        sizePicker.dataSource = self
        
        periodsPicker.delegate = self
        periodsPicker.dataSource = self

    }
    
    @IBAction func onSegCtrlChanged(_ sender: Any) {
        if(lendSellSegCtrl.selectedSegmentIndex == 0) {
            periodsPicker.isHidden = false
            periodsLabel.isHidden = false
            numPeriodsTextField.isHidden = false
            numPeriodsLabel.isHidden = false
        } else {
            periodsPicker.isHidden = true
            periodsLabel.isHidden = true
            numPeriodsTextField.isHidden = true
            numPeriodsLabel.isHidden = true
        }
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView.tag == 0) {
            return categoryPickerData.count
        } else if (pickerView.tag == 1) {
            return sizePickerData.count
        } else {
            return periodsPickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView.tag == 0) {
            return categoryPickerData[row]
        } else if (pickerView.tag == 1) {
            return sizePickerData[row]
        } else {
            return periodsPickerData[row]
        }
    }
    
    @IBAction func onPostButtonClicked(_ sender: Any) {
        var lease = (lendSellSegCtrl.selectedSegmentIndex == 0)
        let categoryPickerRow = categoryPicker.selectedRow(inComponent: 0)
        let categoryValue = String(categoryPickerData[categoryPickerRow])
        let sizePickerRow = sizePicker.selectedRow(inComponent: 0)
        let sizeValue = String(sizePickerData[sizePickerRow])
        let periodsPickerRow = periodsPicker.selectedRow(inComponent: 0)
        let periodsValue = String(periodsPickerData[periodsPickerRow])
        let priceValue = Double(priceTextField.text!) ?? 0
        let numPeriodsValue = Double(numPeriodsTextField.text!) ?? 0
        
        let productData: [String: Any] = [
            "description": descriptionField.text!,
            "id": items.count + 1, //change
            "image": "",
            "lease": lease,
            "name": titleField.text!,
            "numPeriods": numPeriodsValue,
            "period": periodsValue,
            "price": priceValue,
            "size": sizeValue,
            "userID": user //change
        ]
        
        let newProduct = db.collection("products").document()
        
        newProduct.setData(productData) { error in
            if let error = error {
                print("Error creating new product: \(error)")
            } else {
                print("Product successfully created!")
                
            }
        }
        
    }
    
}
