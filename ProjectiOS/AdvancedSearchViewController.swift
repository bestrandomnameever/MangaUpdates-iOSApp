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
    
    @IBOutlet weak var genresUITableView: UITableView!
    

    @IBAction func changeColorSegmented(_ sender: UISegmentedControl) {
        let chosenOption = sender.selectedSegmentIndex
        let index = genresUITableView.indexPath(for: sender.superview?.superview as! GenreIncludeExcludeTableCell)?.row
        switch(chosenOption) {
            case 1:
                categoryItems[index!].1 = 1
            case 2:
                categoryItems[index!].1 = 2
            default:
                categoryItems[index!].1 = 0
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
}

extension AdvancedSearchViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "genreIncludeExcludeCell", for: indexPath) as! GenreIncludeExcludeTableCell
        cell.genreUILabel.text = categoryItems[indexPath.row].0
        cell.includeExcludeUISegmentedControl.selectedSegmentIndex = categoryItems[indexPath.row].1
        cell.includeExcludeUISegmentedControl.tintColor = correctColorFor(segmentNr: categoryItems[indexPath.row].1)
        return cell
    }
}
