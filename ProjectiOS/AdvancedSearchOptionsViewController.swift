//
//  AdvancedSearchOptionsViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 05/03/2017.
//  Copyright © 2017 Anthony. All rights reserved.
//

import UIKit

protocol AdvancedSearchOptionsDelegate {
    func sendOptions(licenseOption: LicenseOptions, extendedOption: ExtendedOptions, typeOption: TypeOptions)
}

class AdvancedSearchOptionsViewController: UIViewController {

    @IBAction func applyOptions(_ sender: Any) {
        delegate.sendOptions(licenseOption: selectedLicenseOption,extendedOption: selectedExtendedOption,typeOption: selectedTypeOption)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelOptions(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var licensePicker: UIPickerView!
    @IBOutlet weak var extendedPicker: UIPickerView!
    @IBOutlet weak var typePicker: UIPickerView!
    
    var delegate: AdvancedSearchOptionsDelegate!
    var licenseOptions: [(name: String, licenseOption: LicenseOptions)] = [
        ("All manga", .all),
        ("Only licensed manga", .onlyLicensed),
        ("Only unlicensed manga", .onlyUnlicensed)
    ]
    var extendedOptions : [(name: String, extendedOption: ExtendedOptions)] = [
        ("All", .all),
        ("Completely scanlated", .completeScanlated),
        ("ompletly scanlated and oneshots", .completeScanlatedIncludingOneShots),
        ("Only oneshots", .oneShot),
        ("Exclude oneshots", .excludeOneShot),
        ("With at least one release", .atLeastOneRelease),
        ("With no releases", .noRelease)
    ]
    var typeOptions: [(name: String, typeOption :TypeOptions)] = [
        ("All", .all),
        ("Artbook", .artbook),
        ("Doujinshi", .doujinshi),
        ("Drama CD", .dramaCd),
        ("Manga", .manga),
        ("Manhwa", .manhwa),
        ("Manhua", .manhua),
        ("Thai", .thai),
        ("Indonesian", .indonesian),
        ("Novel", .novel),
        ("OEL", .oel)
    ]
    var selectedLicenseOption = LicenseOptions.all
    var selectedExtendedOption = ExtendedOptions.all
    var selectedTypeOption = TypeOptions.all
    
    override func viewDidLoad() {
        super.viewDidLoad()
        licensePicker.delegate = self
        licensePicker.dataSource = self
        licensePicker.reloadAllComponents()
        extendedPicker.delegate = self
        extendedPicker.dataSource = self
        extendedPicker.reloadAllComponents()
        typePicker.delegate = self
        typePicker.dataSource = self
        extendedPicker.reloadAllComponents()
        spinToOptionsOfAdvancedSearchMain()
    }

}

extension AdvancedSearchOptionsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case licensePicker:
            return licenseOptions.count
        case extendedPicker:
            return extendedOptions.count
        case typePicker:
            return typeOptions.count
        default:
            return 0
        }
    }

    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case licensePicker:
            return licenseOptions[row].name
        case extendedPicker:
            return extendedOptions[row].name
        case typePicker:
            return typeOptions[row].name
        default:
            return ""
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case licensePicker:
            selectedLicenseOption = licenseOptions[row].licenseOption
        case extendedPicker:
            selectedExtendedOption = extendedOptions[row].extendedOption
        case typePicker:
            selectedTypeOption = typeOptions[row].typeOption
        default:
            break
        }
    }
    
    func spinToOptionsOfAdvancedSearchMain() {
        if selectedLicenseOption != .all {
            let license = licenseOptions.index(where: {$0.licenseOption == selectedLicenseOption})!
            licensePicker.selectRow(license, inComponent: 0, animated: false)
        }
        if selectedExtendedOption != .all {
            let extend = extendedOptions.index(where: {$0.extendedOption == selectedExtendedOption})!
            extendedPicker.selectRow(extend, inComponent: 0, animated: false)
        }
        if selectedTypeOption != .all {
            let type = typeOptions.index(where: {$0.typeOption == selectedTypeOption})!
            typePicker.selectRow(type, inComponent: 0, animated: false)
        }
    }
}
