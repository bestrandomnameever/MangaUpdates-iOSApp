//
//  AdvancedSearchViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 20/11/2016.
//  Copyright © 2016 Anthony. All rights reserved.
//

import UIKit

class AdvancedSearchViewController: UIViewController {
    var genres : [(genreName: String, mode: Int)]!
    
    @IBOutlet weak var searchForTitleField: UITextField!//TODO moet weg
    @IBOutlet weak var genresUITableView: UITableView!
    @IBOutlet weak var onlyScanlatedRadioBtn: UISwitch!
    
    @IBAction func returnPressedEndEditing(_ sender: Any) {
        view.endEditing(true)
    }

    @IBAction func changeColorSegmented(_ sender: UISegmentedControl) {
        let chosenOption = sender.selectedSegmentIndex
        let index = genresUITableView.indexPath(for: sender.superview?.superview as! GenreIncludeExcludeTableCell)?.row
        switch(chosenOption) {
            case 1:
                genres[index!].1 = 1
            case 2:
                genres[index!].1 = 2
            default:
                genres[index!].1 = 0
        }
        sender.tintColor = correctColorFor(segmentNr: chosenOption)
    }
    
    var categorys: [String] = []
    var licenseOption = LicenseOptions.all
    var extendedOption = ExtendedOptions.all
    var typeOption = TypeOptions.all
    
    func correctColorFor(segmentNr : Int) -> UIColor{
        switch(segmentNr) {
            case 1:
                return UIColor.green
            case 2:
                return UIColor.red
            default:
                return UIColor.darkGray
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "search":
            var include : [String] = []
            var exclude : [String] = []
            let searchTitle : String = searchForTitleField.text!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            for genre in genres{
                switch(genre.mode) {
                case 1:
                    include.append(genre.genreName)
                case 2:
                    exclude.append(genre.genreName)
                default:
                    break
                }
            }
            
            let destination = segue.destination as! MangaSearchResultsViewController
            destination.originalSearchUrl = MangaUpdatesURLBuilder.init().includeGenres(include).excludeGenres(exclude).withCategories(categorys).resultsPerPage(amount: 50).licensed(licenseOption).extendedOptions(extendedOption).typeOptions(typeOption).getUrl()
            print(destination.originalSearchUrl.absoluteString)
            destination.searchTitle.title = searchForTitleField.text!
        case "categories":
            let destination = segue.destination as! CategoriesSelectViewController
            destination.selectedCategorys = categorys
            //set delegate to send back categorys
            destination.delegate = self
            break
        case "options":
            let destination = segue.destination as! AdvancedSearchOptionsViewController
            destination.delegate = self
            destination.selectedLicenseOption = licenseOption
            destination.selectedExtendedOption = extendedOption
            destination.selectedTypeOption = typeOption
            break
        default:
            break
        }
    }

}

extension AdvancedSearchViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return genres.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "genreIncludeExcludeCell", for: indexPath) as! GenreIncludeExcludeTableCell
        cell.genreUILabel.text = genres[indexPath.row].0
        cell.includeExcludeUISegmentedControl.selectedSegmentIndex = genres[indexPath.row].1
        cell.includeExcludeUISegmentedControl.tintColor = correctColorFor(segmentNr: genres[indexPath.row].1)
        return cell
    }
}

extension AdvancedSearchViewController : CategoriesSelectViewControllerDelegate, AdvancedSearchOptionsDelegate {
    func sendChosenCategorys(categorys: [String]) {
        self.categorys = categorys
        print(self.categorys)
    }
    
    func sendOptions(licenseOption: LicenseOptions, extendedOption: ExtendedOptions, typeOption: TypeOptions) {
        self.licenseOption = licenseOption
        self.extendedOption = extendedOption
        self.typeOption = typeOption
        print(self.licenseOption, self.extendedOption, self.typeOption)
    }
}
