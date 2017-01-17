//
//  MangaSearchResultsViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 20/11/2016.
//  Copyright © 2016 Anthony. All rights reserved.
//

import UIKit

class MangaSearchResultsViewController: UITableViewController {
    
    var searchUrl : String!
    var results : [MangaSearchResult] = []
    var allResultsLoaded = false
    @IBOutlet var mangaResultsUITableView: UITableView!
    @IBOutlet weak var searchResultsLoadingActivityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        loadResultsForUrl(amountOfPages: 3)
    }
    
    func loadResultsForUrl(amountOfPages: Int) {
        DispatchQueue.global(qos: .userInitiated).async {
            //load 3 pages of manga's
            var url = self.searchUrl
            for _ in 1...amountOfPages{
                //get all id's of mangas matching this searchUrl
                let searchUrl = URL.init(string: url!)
                let mangaIdsAndNextPageUrl = MangaUpdatesAPI.getMangaIdsFrom(searchUrl: searchUrl!)
                //make sure that all ids are unique since 1 manga can appear more than once in search thanks to alternative names
                var uniqueMangaIds : [String] = []
                for id in mangaIdsAndNextPageUrl.ids{
                    if(!uniqueMangaIds.contains(id)){
                        uniqueMangaIds.append(id)
                    }
                }
                for mangaId in uniqueMangaIds {
                    if let mangaResult = MangaUpdatesAPI.getMangaSearchResultWithId(id: mangaId){
                        self.results.append(mangaResult)
                    }
                    DispatchQueue.main.async {
                        self.mangaResultsUITableView.reloadData()
                        //TODO images van uhm "questionalble" manga laden niet
                        //print(self.results.flatMap({$0.title+" "+$0.image}))
                    }
                }
                //set url to next page of results
                if let nextPageUrl = mangaIdsAndNextPageUrl.moreResultsUrl {
                    url = nextPageUrl
                }else{
                    DispatchQueue.main.async {
                        self.allResultsLoaded = true
                        self.mangaResultsUITableView.reloadData()
                    }
                    break
                }
            }
            //update searchUrl in main if a new page has to be loaded
            DispatchQueue.main.async {
                self.searchUrl = url
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! MangaDetailViewController
        let index = mangaResultsUITableView.indexPathsForSelectedRows!.first!.row
        destination.mangaId = results[index].id
        destination.mangaCoverUrl = results[index].image
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count+1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.row == results.count && allResultsLoaded){
            let cell = tableView.dequeueReusableCell(withIdentifier: "noResultsFoundCell", for: indexPath) as! NoResultsFoundTableCell
            return cell
        }else if indexPath.row == results.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "moreSearchResultsLoadingCell", for: indexPath) as! MoreSearchResultsLoadingCell
            cell.loadingMoreActivityIndicator.startAnimating()
            return cell
        } else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "MangaSearchResultCell", for: indexPath) as! SearchResultMangaTableCell
            let mangaResult = results[indexPath.item]
            cell.titleUILabel.text = mangaResult.title
            cell.authorUILabel.text = mangaResult.author
            cell.coverUIImageView.sd_setImage(with: URL.init(string: mangaResult.image))
            cell.genresUILabel.text = mangaResult.genres.joined(separator: ", ")
            cell.scoreUILabel.text = mangaResult.score + "/10"
            return cell
        }
    }
}
