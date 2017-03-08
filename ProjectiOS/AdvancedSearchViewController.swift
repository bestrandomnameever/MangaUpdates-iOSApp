//
//  AdvancedSearchViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 20/11/2016.
//  Copyright © 2016 Anthony. All rights reserved.
//

import UIKit
import TagListView

class AdvancedSearchViewController: UIViewController {
    var genres : [(genreName: String, mode: Int)]!
    
    @IBOutlet weak var genresUITableView: UITableView!
    @IBOutlet weak var licenseLabel: UILabel!
    @IBOutlet weak var extendedLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var tagListView: TagListView!

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
    var licenseOption = ""
    var extendedOption = ""
    var typeOption = ""
    
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
            destination.searchTitle.title = "Results"
        case "categories":
            let destination = segue.destination as! CategoriesSelectViewController
            destination.selectedCategorys = categorys
            //set delegate to send back categorys
            destination.delegate = self
            break
        case "licenseOptions":
            let destination = segue.destination as! AdvancedSearchOptionsViewController
            destination.delegate = self
            destination.selectedOption = ("",licenseOption)
            destination.optionType = OptionType.licenseType
        case "extendedOptions":
            let destination = segue.destination as! AdvancedSearchOptionsViewController
            destination.delegate = self
            destination.selectedOption = ("",extendedOption)
            destination.optionType = OptionType.extendedType
        case "typeOptions":
            let destination = segue.destination as! AdvancedSearchOptionsViewController
            destination.delegate = self
            destination.selectedOption = ("",typeOption)
            destination.optionType = OptionType.typeType
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
    internal func sendOptions(optionType: OptionType, selectedOption: (String, String)) {
        switch optionType {
            case OptionType.licenseType:
            licenseLabel.text = selectedOption.0
            licenseOption = selectedOption.1
            case OptionType.extendedType:
            extendedLabel.text = selectedOption.0
            extendedOption = selectedOption.1
            case OptionType.typeType:
            typeLabel.text = selectedOption.0
            typeOption = selectedOption.1
        }
    }

    func sendChosenCategorys(categorys: [String]) {
        self.categorys = categorys
        tagListView.removeAllTags()
        for category in self.categorys {
            tagListView.addTag(category)
        }
    }
}
