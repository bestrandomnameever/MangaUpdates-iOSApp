//
//  MangaSearchResultsViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 20/11/2016.
//  Copyright © 2016 Anthony. All rights reserved.
//

import UIKit

class MangaSearchResultsViewController: UITableViewController {
    
    var searchString : String?
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MangaSearchResultCell", for: indexPath) as! SearchResultMangaTableCell
        cell.titleUILabel.text = "Kimi no iru machi"
        cell.authorUILabel.text = "Kawaidesu"
        cell.genresUILabel.text = "Luvluv, andere shit, en boobs, en poepen"
        cell.scoreUILabel.text = "10/10"
        return cell
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        switch segue.identifier! {
//        case "vote":
//            let destination = segue.destination as! VotingViewController
//            let selectedIndex = tableView.indexPathForSelectedRow!.row
//            destination.color = model.scores[selectedIndex].color
//        default:
//            break
//        }
//    }
}
