//
//  MangaSearchResultsViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 20/11/2016.
//  Copyright © 2016 Anthony. All rights reserved.
//

import UIKit

class MangaSearchResultsViewController: UITableViewController {
    
    var searchUrl : String?
    var mangas : [Manga] = []
    @IBOutlet var mangaResultsUITableView: UITableView!
    
    override func viewDidLoad() {
        DispatchQueue.global(qos: .userInitiated).async {
            let mangaIds = MangaUpdatesAPI.getMangaIdsFrom(searchUrl: URL.init(string: self.searchUrl!)!)
            print(mangaIds)
            DispatchQueue.main.async {
                for mangaId in mangaIds {
                    DispatchQueue.global(qos: .userInitiated).async {
                        self.mangas.append(MangaUpdatesAPI.getMangaWithId(id: mangaId)!)
                        DispatchQueue.main.async {
                            self.mangaResultsUITableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! MangaDetailViewController
        let index = mangaResultsUITableView.indexPathsForSelectedRows!.first!.row
        destination.manga = mangas[index]
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mangas.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MangaSearchResultCell", for: indexPath) as! SearchResultMangaTableCell
        let manga = mangas[indexPath.item]
        cell.titleUILabel.text = manga.title
        cell.authorUILabel.text = manga.author
        cell.coverUIImageView.sd_setImage(with: URL.init(string: manga.image))
        cell.genresUILabel.text = manga.genres.joined(separator: ", ")
        cell.scoreUILabel.text = manga.score + "/10"
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
