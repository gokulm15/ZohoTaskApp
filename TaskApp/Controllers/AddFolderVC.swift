//
//  AddFolderVC.swift
//  TaskApp
//
//  Created by gokul on 31/03/24.
//

import UIKit
import CoreData
class AddFolderVC: UIViewController {
    
    @IBOutlet weak var folderNameTxt: UITextField!
    @IBOutlet weak var colorBgView: UIView!
    @IBOutlet weak var colorNameLbl: UILabel!
    @IBOutlet weak var colorWell: UIColorWell!
    var colorCode: String?
    var coreDataManager = CoreDataManager.shared
    var helperClass = HelperClass.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        uiConfig()
    }
    func uiConfig() {
        self.navigationItem.title = "Add Folder"
        let saveBarBtn = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveAction))
        let cancelBarBtn = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(cancelAction))
        
        self.navigationItem.rightBarButtonItem = saveBarBtn
        self.navigationItem.leftBarButtonItem = cancelBarBtn
        
        colorWell.addTarget(self, action: #selector(colorWellDidChange(_:)), for: .valueChanged)
        
        colorBgView.addCardStyle()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(colorTapped))
        colorBgView.addGestureRecognizer(tapGesture)
    }
    
    @objc func saveAction() {
        if let folderName = folderNameTxt.text, !folderName.isEmpty, let code = colorCode {
            self.coreDataManager.addFolder(folderName: folderName, colorCode: code) {
                self.dismiss(animated: true)
            }
        } else {
            let alert = UIAlertController(title: "Alert!", message: "All fields are mandatory", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    @objc func cancelAction() {
        self.dismiss(animated: true)
    }
    
    @objc func colorTapped() {
        // Present the UIColorPickerViewController
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        present(colorPicker, animated: true, completion: nil)
    }
    @objc func colorWellDidChange(_ sender: UIColorWell) {
        self.colorCode = helperClass.colorCode(with: sender.selectedColor ?? UIColor.systemBackground)
    }
    
}

extension AddFolderVC: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        let selectedColor = viewController.selectedColor
        colorWell.selectedColor = selectedColor
        self.colorCode = helperClass.colorCode(with: colorWell.selectedColor ?? UIColor.systemBackground)
    }
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let selectedColor = viewController.selectedColor
        colorWell.selectedColor = selectedColor
        self.colorCode = helperClass.colorCode(with: colorWell.selectedColor ?? UIColor.systemBackground)
    }
}

