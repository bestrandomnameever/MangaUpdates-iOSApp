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
    
    @IBOutlet weak var searchForTitleField: UITextField!
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
            var filter : ExtendedOptions = .all
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
            if onlyScanlatedRadioBtn.isOn{
                filter = ExtendedOptions.completeScanlated
            }
            
            let destination = segue.destination as! MangaSearchResultsViewController
            destination.originalSearchUrl = MangaUpdatesURLBuilder.init().searchTitle(searchTitle).includeGenres(include).excludeGenres(exclude).resultsPerPage(amount: 50).extendedOptions(filter).getUrl()
            destination.searchTitle.title = searchForTitleField.text!
        case "categories":
            let destination = segue.destination as! CategoriesSelectViewController
            //set delegate to send back categorys
            destination.delegate = self
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

extension AdvancedSearchViewController : CategoriesSelectViewControllerDelegate {
    func sendChosenCategorys(categorys: [String]) {
        self.categorys = categorys
        print(self.categorys)
    }
}
