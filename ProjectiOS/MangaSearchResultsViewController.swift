//
//  MangaSearchResultsViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 20/11/2016.
//  Copyright © 2016 Anthony. All rights reserved.
//

import UIKit

class MangaSearchResultsViewController: UITableViewController {
    
    var originalSearchUrl : URL!
    var currentUrl : URL!
    var results : [MangaSearchResult] = []
    var allResultsLoaded = false
    var lastActivatedFilter = SortOption.Reset
    var currentPage = 1
    let loadMangaQueue = DispatchQueue.init(label: "loadMangaQueue")
    let loadMangaOperationQueue = OperationQueue.init()
    @IBOutlet var mangaResultsUITableView: UITableView!
    
    @IBOutlet weak var resetSortItem: UIBarButtonItem!
    @IBOutlet weak var alphaSortItem: UIBarButtonItem!
    @IBOutlet weak var scoreSortItem: UIBarButtonItem!
    @IBAction func resetSort(_ sender: Any) {
        order(on: SortOption.Reset);
    }
    @IBAction func alphabetSort(_ sender: Any) {
        order(on: SortOption.OnAlpha);
    }
    @IBAction func scoreSort(_ sender: Any) {
        order(on: SortOption.OnScore);
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        currentUrl = originalSearchUrl
        loadResultsForUrl(amountOfPages: 3)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            let destination = segue.destination as! MangaDetailViewContainerController
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


//Methods to load results matching to searchUrl
extension MangaSearchResultsViewController{
    func loadResultsForUrl(amountOfPages: Int) {
        loadMangaQueue.async {
            var page = self.currentPage
            var hasNextPage = true
            //load 3 pages of manga's
            for _ in 1...amountOfPages{
                let url = MangaUpdatesURLBuilder.init(customUrl: self.currentUrl).getPage(page: page).getUrl()
                //get all id's of mangas matching this searchUrl
                self.loadMangaOperationQueue.addOperation {
                    let mangaIdsAndNextPageUrl = MangaUpdatesAPI.getMangaIdsFrom(searchUrl: url)
                    OperationQueue.main.addOperation {
                        var uniqueMangaIds : [String] = []
                        //make sure that all ids are unique since 1 manga can appear more than once in search thanks to alternative names
                        for id in mangaIdsAndNextPageUrl.ids{
                            if(!uniqueMangaIds.contains(id)){
                                uniqueMangaIds.append(id)
                            }
                        }
                        for mangaId in uniqueMangaIds {
                            self.loadMangaOperationQueue.addOperation {
                                if let mangaResult = MangaUpdatesAPI.getMangaSearchResultWithId(id: mangaId){
                                    self.results.append(mangaResult)
                                    OperationQueue.main.addOperation {
                                        self.mangaResultsUITableView.reloadData()
                                    }
                                }
                            }
                        }
                        if mangaIdsAndNextPageUrl.hasNextPage {
                            hasNextPage = false
                        }
                    }
                }
                
                //set url to next page of results
                if hasNextPage {
                    page = page + 1
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
                self.currentPage = page
            }
        }
    }
}


//Handle the filters in the toolbar
extension MangaSearchResultsViewController{
    func order(on: SortOption){
        getItemBy(identifier: lastActivatedFilter).tintColor = UIColor.blue
        if(on != lastActivatedFilter){
            getItemBy(identifier: lastActivatedFilter).tintColor = UIColor.blue
            lastActivatedFilter = on
            if(on != SortOption.Reset){
                getItemBy(identifier: on).tintColor = UIColor.orange
            }
            results.removeAll()
            mangaResultsUITableView.reloadData()
            switch(on){
            case SortOption.OnAlpha:
                self.currentPage = 1
                currentUrl = MangaUpdatesURLBuilder.init(customUrl: originalSearchUrl).orderBy(.title).resultsPerPage(amount: 50).getUrl()
                print(currentUrl.absoluteString)
                loadResultsForUrl(amountOfPages: 1)
            case SortOption.OnScore:
                self.currentPage = 1
                currentUrl = MangaUpdatesURLBuilder.init(customUrl: originalSearchUrl).orderBy(.rating).resultsPerPage(amount: 50).getUrl()
                print(currentUrl.absoluteString)
                loadResultsForUrl(amountOfPages: 1)
            default:
                self.currentPage = 1
                currentUrl = originalSearchUrl
                print(currentUrl.absoluteString)
                loadResultsForUrl(amountOfPages: 3)
            }
        }
    }
    
    func getItemBy(identifier: SortOption) -> UIBarButtonItem{
        switch(identifier){
            case SortOption.Reset:
                return resetSortItem
            case SortOption.OnAlpha:
                return alphaSortItem
            case SortOption.OnScore:
                return scoreSortItem
        }
    }
}

enum SortOption{
    case OnScore
    case OnAlpha
    case Reset
}
