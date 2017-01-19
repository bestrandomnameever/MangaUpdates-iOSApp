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
    var mangaCoverUrl : String!
    @IBOutlet weak var categoryRecommendationsLoading: UIActivityIndicatorView!
    @IBOutlet weak var recommendationsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.global(qos: .default).async {
            for id in self.manga.categoryRecommendationsIds {
                if let mangaResult = MangaUpdatesAPI.getMangaSearchResultWithId(id: id) {
                    DispatchQueue.main.async {
                        self.categoryRecommendations.append(mangaResult)
                    }
                }
            }
            DispatchQueue.main.async {
                self.categoryRecommendationsLoading.stopAnimating()
                self.recommendationsTableView.reloadData()
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
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if(manga.categoryRecommendationsIds.count == 0){
                return 1
            }
            return categoryRecommendations.count
        }else{
            if(manga.recommendationsIds.count == 0){
                return 1
            }
            return recommendations.count
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section{
            case 0: return "Category Recommendations"
            case 1: return "Recommendations"
            default: break
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            if(manga.categoryRecommendationsIds.count == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: "notFoundCell", for: indexPath) as! NoResultsFoundTableCell
                cell.cellMesage.text = "No category recommendations"
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
        }else{
            if(manga.recommendationsIds.count == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: "notFoundCell", for: indexPath) as! NoResultsFoundTableCell
                cell.cellMesage.text = "No recommendations"
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
