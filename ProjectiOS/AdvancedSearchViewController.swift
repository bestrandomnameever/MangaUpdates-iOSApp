//
//  AdvancedSearchViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 20/11/2016.
//  Copyright © 2016 Anthony. All rights reserved.
//

import UIKit

class AdvancedSearchViewController: UIViewController {
    var categoryItems = [("Action", 0), ("Adult", 0), ("Adventure", 0), ("Comedy", 0), ("Doujinshi", 0), ("Drama", 0), ("Ecchi", 0), ("Fantasy", 0), ("Gender Bender", 0), ("Harem", 0), ("Action", 0), ("Adult", 0), ("Adventure", 0), ("Comedy", 0), ("Doujinshi", 0), ("Drama", 0), ("Ecchi", 0), ("Fantasy", 0), ("Gender Bender", 0), ("Harem", 0)]
    var genres : [(genreName: String, mode: Int)]!
    
    @IBOutlet weak var genresUITableView: UITableView!
    @IBOutlet weak var onlyScanlatedRadioBtn: UISwitch!
    

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
        var include : [String] = []
        var exclude : [String] = []
        var filter : ExtendedOptions = .all
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
        destination.originalSearchUrl = MangaUpdatesURLBuilder.init().includeGenres(include).excludeGenres(exclude).resultsPerPage(amount: 50).extendedOptions(filter).getUrl()
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
