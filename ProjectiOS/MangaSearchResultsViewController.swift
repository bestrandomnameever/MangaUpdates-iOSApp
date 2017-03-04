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
    var pageTitle = ""
    var currentUrl : URL!
    var results : [MangaSearchResult] = []
    var allResultsLoaded = false
    var lastActivatedFilter = SortOption.Reset
    var currentPage = 0
    var doneLoading = true
    var idsCount = 0
    let amountOfResultsPerLoad = 50
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
    @IBOutlet weak var searchTitle: UINavigationItem!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: true)
    }
    
    override func viewDidLoad() {
        if(!pageTitle.isEmpty){
            searchTitle.title = pageTitle
        }
        currentUrl = originalSearchUrl
        loadResultsForUrl(amount: amountOfResultsPerLoad)
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if(indexPath.row > results.count-10 && doneLoading && !allResultsLoaded){
            loadResultsForUrl(amount: amountOfResultsPerLoad)
        }
    }
}


//Methods to load results matching to searchUrl
extension MangaSearchResultsViewController{
    
    func loadResultsForUrl(amount: Int) {
        self.doneLoading = false
        loadMangaOperationQueue.addOperation {
            let page = self.currentPage + 1
            let url = MangaUpdatesURLBuilder.init(customUrl: self.currentUrl).getPage(page: page).resultsPerPage(amount: amount).getUrl()
            //get all id's of mangas matching this searchUrl
            let mangaIdsAndNextPageUrl = MangaUpdatesAPI.getMangaIdsFrom(searchUrl: url)
            OperationQueue.main.addOperation {
                var uniqueMangaIds : [String] = []
                //make sure that all ids are unique since 1 manga can appear more than once in search thanks to alternative names
                for id in mangaIdsAndNextPageUrl.ids{
                    if(!uniqueMangaIds.contains(id)){
                        uniqueMangaIds.append(id)
                    }
                }
                self.idsCount = self.idsCount + uniqueMangaIds.count
                for mangaId in uniqueMangaIds {
//                    self.loadMangaOperationQueue.addOperation {
//                        if let mangaResult = MangaUpdatesAPI.getMangaSearchResultWithId(id: mangaId){
//                            OperationQueue.main.addOperation {
//                                self.results.append(mangaResult)
//                                self.mangaResultsUITableView.reloadData()
//                                if(self.results.count == self.idsCount){
//                                    self.doneLoading = true
//                                }
//                            }
//                        }
//                    }
                    MangaUpdatesAPI.getMangaSearchResultWithId(id: mangaId, completionHandler: { (mangaResult) in
                        if mangaResult != nil {
                            self.results.append(mangaResult!)
                            self.mangaResultsUITableView.reloadData()
                            if(self.results.count == self.idsCount){
                                self.doneLoading = true
                            }
                        }
                    })
                }
                if mangaIdsAndNextPageUrl.hasNextPage {
                    self.currentPage = page
                }else{
                    self.allResultsLoaded = true
                    self.mangaResultsUITableView.reloadData()
                }
            }
        }
        
    }
}


//Handle the filters in the toolbar
extension MangaSearchResultsViewController{
    
    func order(on: SortOption){
        //getItemBy(identifier: lastActivatedFilter).tintColor = UIColor.init(red: 1.00, green: 0.60, blue: 0.20, alpha: 1.0)
        if(on != lastActivatedFilter){
            getItemBy(identifier: lastActivatedFilter).tintColor = UIColor.init(red: 1.00, green: 0.60, blue: 0.20, alpha: 1.0)
            lastActivatedFilter = on
            if(on != SortOption.Reset){
                getItemBy(identifier: on).tintColor = UIColor.init(red: 0.89, green: 0.47, blue: 0.06, alpha: 1.0)
            }
            results.removeAll()
            //indien nog tijd over, zoek uit
            loadMangaOperationQueue.cancelAllOperations()
            mangaResultsUITableView.reloadData()
            switch(on){
            case SortOption.OnAlpha:
                self.currentPage = 0
                currentUrl = MangaUpdatesURLBuilder.init(customUrl: originalSearchUrl).orderBy(.title).getUrl()
                loadResultsForUrl(amount: amountOfResultsPerLoad)
            case SortOption.OnScore:
                self.currentPage = 0
                currentUrl = MangaUpdatesURLBuilder.init(customUrl: originalSearchUrl).orderBy(.rating).getUrl()
                loadResultsForUrl(amount: amountOfResultsPerLoad)
            default:
                self.currentPage = 0
                currentUrl = originalSearchUrl
                loadResultsForUrl(amount: amountOfResultsPerLoad)
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
