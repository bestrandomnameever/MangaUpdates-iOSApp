//
//  AdvancedSearchOptionsViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 05/03/2017.
//  Copyright © 2017 Anthony. All rights reserved.
//

import UIKit

protocol AdvancedSearchOptionsDelegate {
    func sendOptions(optionType: OptionType, selectedOption: (String,String))
}

class AdvancedSearchOptionsViewController: UIViewController {

    @IBAction func applyOptions(_ sender: Any) {
        delegate.sendOptions(optionType: self.optionType, selectedOption: self.selectedOption)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelOptions(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func tapBesideBox(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var optionTypeLabel: UILabel!
    @IBOutlet weak var optionPicker: UIPickerView!
    
    
    var delegate: AdvancedSearchOptionsDelegate!
    var licenseOptions: [(name: String, urlExtension: String)] = [
        ("All manga", ""),
        ("Only licensed manga", "yes"),
        ("Only unlicensed manga", "no")
    ]
    var extendedOptions : [(name: String, urlExtension: String)] = [
        ("All", ""),
        ("Completely scanlated", "scanlated"),
        ("ompletly scanlated and oneshots", "completed"),
        ("Only oneshots", "oneshots"),
        ("Exclude oneshots", "no_oneshots"),
        ("With at least one release", "some_releases"),
        ("With no releases", "no_releases")
    ]
    var typeOptions: [(name: String, urlExtension: String)] = [
        ("All", ""),
        ("Artbook", "artbook"),
        ("Doujinshi", "doujinshi"),
        ("Drama CD", "drama_cd"),
        ("Manga", "manga"),
        ("Manhwa", "manhwa"),
        ("Manhua", "manhua"),
        ("Thai", "thai"),
        ("Indonesian", "indonesian"),
        ("Novel", "novel"),
        ("OEL", "oel")
    ]
    var optionType: OptionType!
    var selectedOption: (name: String, urlExtension: String) = ("All", "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        optionPicker.delegate = self
        optionPicker.dataSource = self
        spinToOptionsOfAdvancedSearchMain()
    }

}

extension AdvancedSearchOptionsViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch optionType! {
        case OptionType.licenseType:
            return licenseOptions.count
        case OptionType.extendedType:
            return extendedOptions.count
        case OptionType.typeType:
            return typeOptions.count
        }
    }

    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch optionType! {
        case OptionType.licenseType:
            return licenseOptions[row].name
        case OptionType.extendedType:
            return extendedOptions[row].name
        case OptionType.typeType:
            return typeOptions[row].name
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch optionType! {
        case OptionType.licenseType:
            selectedOption = licenseOptions[row]
        case OptionType.extendedType:
            selectedOption = extendedOptions[row]
        case OptionType.typeType:
            selectedOption = typeOptions[row]
        }
    }
    
    func spinToOptionsOfAdvancedSearchMain() {
        if selectedOption.name != "" {
            switch optionType! {
            case OptionType.licenseType:
                let position = licenseOptions.index(where: {$0.urlExtension == selectedOption.urlExtension})!
                optionPicker.selectRow(position, inComponent: 0, animated: false)
            case OptionType.extendedType:
                let position = extendedOptions.index(where: {$0.urlExtension == selectedOption.urlExtension})!
                optionPicker.selectRow(position, inComponent: 0, animated: false)
            case OptionType.typeType:
                let position = typeOptions.index(where: {$0.urlExtension == selectedOption.urlExtension})!
                optionPicker.selectRow(position, inComponent: 0, animated: false)
            }
        }
    }
}

enum OptionType{
    case licenseType
    case extendedType
    case typeType
}
