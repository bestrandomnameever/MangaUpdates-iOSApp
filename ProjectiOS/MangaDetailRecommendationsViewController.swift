//
//  TestOneViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 18/01/2017.
//  Copyright © 2017 Anthony. All rights reserved.
//

import UIKit

class MangaDetailRecommendationsViewController: UIViewController {
    
    var manga : Manga!
    var recommendations : [MangaSearchResult] = []
    var categoryRecommendations : [MangaSearchResult] = []
    var relatedSeries: [MangaSearchResult] = []
    var mangaCoverUrl : String!
    @IBOutlet weak var recommendationsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global(qos: .default).async {
            for id in self.manga.relatedSeriesIds {
                if let mangaResult = MangaUpdatesAPI.getMangaSearchResultWithId(id: id) {
                    DispatchQueue.main.async {
                        self.relatedSeries.append(mangaResult)
                        self.recommendationsTableView.reloadData()
                    }
                }
            }
            for id in self.manga.categoryRecommendationsIds {
                if let mangaResult = MangaUpdatesAPI.getMangaSearchResultWithId(id: id) {
                    DispatchQueue.main.async {
                        self.categoryRecommendations.append(mangaResult)
                        self.recommendationsTableView.reloadData()
                    }
                }
            }
            for id in self.manga.recommendationsIds {
                if let mangaResult = MangaUpdatesAPI.getMangaSearchResultWithId(id: id) {
                    DispatchQueue.main.async {
                        self.recommendations.append(mangaResult)
                        self.recommendationsTableView.reloadData()
                    }
                }
            }
        }
    }
    
}

extension MangaDetailRecommendationsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if(manga.relatedSeriesIds.count == 0){
                return 1
            }else if manga.relatedSeriesIds.count != relatedSeries.count {
                return relatedSeries.count + 1
            }else{
                return relatedSeries.count
            }
        }else if section == 1{
            if(manga.categoryRecommendationsIds.count == 0){
                return 1
            }else if manga.categoryRecommendationsIds.count != categoryRecommendations.count {
                return categoryRecommendations.count + 1
            }else{
                return categoryRecommendations.count
            }
        }else{
            if(manga.recommendationsIds.count == 0){
                return 1
            }else if manga.recommendationsIds.count != recommendations.count {
                return recommendations.count + 1
            }else{
                return recommendations.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
            case 0: return "Related Series"
            case 1: return "Category Recommendations"
            case 2: return "Recommendations"
            default: return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if(manga.relatedSeriesIds.count == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: "notFoundCell", for: indexPath) as! NoResultsFoundTableCell
                cell.cellMesage.text = "No related series"
                return cell
            }else if manga.relatedSeriesIds.count != relatedSeries.count && indexPath.row == relatedSeries.count{
                let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! MoreSearchResultsLoadingCell
                cell.loadingMoreActivityIndicator.startAnimating()
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MangaCategoryRecommendationCell", for: indexPath) as! SearchResultMangaTableCell
                let mangaResult = relatedSeries[indexPath.row]
                cell.titleUILabel.text = mangaResult.title
                cell.authorUILabel.text = mangaResult.author
                cell.coverUIImageView.sd_setImage(with: URL.init(string: mangaResult.image))
                cell.genresUILabel.text = mangaResult.genres.joined(separator: ", ")
                cell.scoreUILabel.text = mangaResult.score + "/10"
                return cell
            }
        }else if indexPath.section == 1{
            if(manga.categoryRecommendationsIds.count == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: "notFoundCell", for: indexPath) as! NoResultsFoundTableCell
                cell.cellMesage.text = "No category recommendations"
                return cell
            }else if manga.categoryRecommendationsIds.count != categoryRecommendations.count && indexPath.row == categoryRecommendations.count{
                let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! MoreSearchResultsLoadingCell
                cell.loadingMoreActivityIndicator.startAnimating()
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MangaCategoryRecommendationCell", for: indexPath) as! SearchResultMangaTableCell
                let mangaResult = categoryRecommendations[indexPath.row]
                cell.titleUILabel.text = mangaResult.title
                cell.authorUILabel.text = mangaResult.author
                cell.coverUIImageView.sd_setImage(with: URL.init(string: mangaResult.image))
                cell.genresUILabel.text = mangaResult.genres.joined(separator: ", ")
                cell.scoreUILabel.text = mangaResult.score + "/10"
                return cell
            }
        }else {
            if(manga.recommendationsIds.count == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: "notFoundCell", for: indexPath) as! NoResultsFoundTableCell
                cell.cellMesage.text = "No recommendations"
                return cell
            }else if manga.recommendationsIds.count != recommendations.count && indexPath.row == recommendations.count{
                let cell = tableView.dequeueReusableCell(withIdentifier: "loadingCell", for: indexPath) as! MoreSearchResultsLoadingCell
                cell.loadingMoreActivityIndicator.startAnimating()
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "MangaCategoryRecommendationCell", for: indexPath) as! SearchResultMangaTableCell
                let mangaResult = recommendations[indexPath.row]
                cell.titleUILabel.text = mangaResult.title
                cell.authorUILabel.text = mangaResult.author
                cell.coverUIImageView.sd_setImage(with: URL.init(string: mangaResult.image))
                cell.genresUILabel.text = mangaResult.genres.joined(separator: ", ")
                cell.scoreUILabel.text = mangaResult.score + "/10"
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let container = parent as! MangaDetailViewContainerController
        var chosen : MangaSearchResult
        if(indexPath.section == 0){
            chosen = relatedSeries[indexPath.row]
        }else if indexPath.section == 1{
            chosen = categoryRecommendations[indexPath.row]
        }else{
            chosen = recommendations[indexPath.row]
        }
        container.mangaId = chosen.id
        container.mangaCoverUrl = chosen.image
        container.segments.isHidden = true
        container.viewDidLoad()
        removeFromParentViewController()
    }
}
