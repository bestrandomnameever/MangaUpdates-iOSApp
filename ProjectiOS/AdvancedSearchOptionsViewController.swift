//
//  AdvancedSearchOptionsViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 05/03/2017.
//  Copyright © 2017 Anthony. All rights reserved.
//

import UIKit

protocol AdvancedSearchOptionsDelegate {
    func sendOptions()
}

class AdvancedSearchOptionsViewController: UIViewController {

    @IBAction func applyOptions(_ sender: Any) {
        
    }
    @IBAction func cancelOptions(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var licensePicker: UIPickerView!
    @IBOutlet weak var extendedPicker: UIPickerView!
    @IBOutlet weak var typePicker: UIPickerView!
    
    var delegate: AdvancedSearchOptionsDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}
