//
//  AddItemViewController.swift
//  BevoPlace
//
//  Created by Navita Dhillon on 11/1/23.
//

import UIKit
import AVFoundation
import FirebaseStorage

let storageRef = Storage.storage().reference()
var categoryPickerData = ["Tickets", "Clothes", "Textbooks", "UT Merch", "Stationary", "Electronics", "Travel", "Other"]
var sizePickerData = ["N/A", "XS", "S", "M", "L", "XL"]
var periodsPickerData = ["day", "week", "month"]
var imageClick = false


class AddItemViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var postItemButton: UIButton!
    
    let picker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postItemButton.layer.cornerRadius = 10
        
        picker.delegate = self
        
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        sizePicker.delegate = self
        sizePicker.dataSource = self
        
        periodsPicker.delegate = self
        periodsPicker.dataSource = self

    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
    
    @IBAction func onCameraButtonPressed(_ sender: Any) {
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            // there is a rear camera available
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) {
                    (accessGranted) in
                    guard accessGranted == true else { return }
                }
            case .authorized:
                break
            default:
                print("Access was previously denied")
                return
            }
            
            // we have authorization;  now do stuff
            picker.allowsEditing = false
            picker.sourceType = .camera
            picker.cameraCaptureMode = .photo
            present(picker,animated: true)
            
        } else {
            
            // there is no rear camera
            let alertVC = UIAlertController(title: "No camera", message: "Sorry, this device has no rear camera", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default)
            alertVC.addAction(okAction)
            present(alertVC,animated:true)
        }
    }
    
    @IBAction func onUploadImageButtonPressed(_ sender: Any) {
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker,animated:true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // get the selected picture
        let chosenImage = info[.originalImage] as! UIImage
        
        // shrink it to a visible size
        imageView.contentMode = .scaleAspectFit
        
        // put the picture into the imageView
        imageView.image = chosenImage
        
        // dismiss the popover
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("User cancelled")
        dismiss(animated: true)
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
        
        if (titleField.text == ""){
            statusLabel.text = "Please enter a title"
        } else if (descriptionField.text == ""){
            statusLabel.text = "Please enter a description"
        } else if ((imageView.image?.pngData() == nil)) {
            statusLabel.text = "Please add a photo"
        } else {
            let newProduct = db.collection("products").document()
            
            // set upload path
            let photoRef = storageRef.child("image/\(newProduct.documentID)/productPhoto")
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            // Upload data and metadata
            if let uploadData = imageView.image?.pngData() {
                photoRef.putData(imageView.image!.pngData()!, metadata: metadata) { (metadata, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    } else {
                        
                    }
                }
                
                let productData: [String: Any] = [
                    "description": descriptionField.text!,
                    "id": items.count+1,
                    "category": categoryValue,
                    "image": "image/\(newProduct.documentID)/productPhoto",
                    "lease": lease,
                    "name": titleField.text!,
                    "numPeriods": numPeriodsValue,
                    "period": periodsValue,
                    "price": priceValue,
                    "size": sizeValue,
                    "userID": user,
                    "docID": newProduct.documentID
                ]
                
                newProduct.setData(productData) { error in
                    if let error = error {
                        print("Error creating new product: \(error)")
                        self.statusLabel.text = "Error creating new product: \(error)"
                    } else {
                        print("Product successfully created!")
                        self.statusLabel.text = "Product successfully created!"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.dismiss(animated: true)
                        }
                        
                        
                    }
                }
            }
        }
//        let otherVC = delegate as! TableProtocol
//        otherVC.fetchAllProducts()
        
    }
    
}
