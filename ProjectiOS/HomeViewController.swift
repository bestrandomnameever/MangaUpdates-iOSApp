//
//  HomeViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 19/11/2016.
//  Copyright © 2016 Anthony. All rights reserved.
//

import UIKit
import Kanna

class HomeViewController : UIViewController {
    
    // MARK: - Predefined variables and IBOutlets
    @IBOutlet weak var mangaCoverCollectionView : UICollectionView!
    @IBOutlet weak var categoryCollectionView : UICollectionView!
    @IBOutlet weak var searchBarUITextField: UITextField!
    
    @IBOutlet weak var releaseCoversLoadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var genreLoadingActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var organiserView : UIView!
    @IBOutlet weak var mangaCoverCollectionHeight : NSLayoutConstraint!
    
    var ids : [String] = []
    var genreItems : [(genre: String, url: URL)] = []
    var mangaCoverItems : [(id: String ,title: String, image: String)] = []
    var coversAreLoading = true
    let batchSize = 30
    
    let reuseIdentifierCoverCell = "mangaCoverCell"
    let reuseIdentifierCategoryCell = "categoryCell"
    let reuseIdentifierReleasesLoading = "releaseCoverLoadingCell"
    
    let spacingTwoCollectionViews = CGFloat.init(2)
    let coverMinHeight = 230
    var coverHeight = CGFloat.init(250)
    let coverMaxHeight = 280
    var coverWidth : CGFloat!
    let categorysHeight = CGFloat.init(45)
    let strokeAttributes = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSStrokeWidthAttributeName: -2,
        NSFontAttributeName : UIFont.boldSystemFont(ofSize: 22)
    ] as [String : Any]
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        loadGenresAsync()
        loadfirstReleasesAsync(amount: batchSize)
    }
    
    func loadGenresAsync(){
        DispatchQueue.global(qos: .userInitiated).async {
            if let genresAndUrls = MangaUpdatesAPI.getGenresAndUrls() {
                DispatchQueue.main.async {
                    if(genresAndUrls.count == 0){
                        self.loadGenresAsync()
                    }else{
                        self.genreItems = genresAndUrls
                        self.genreLoadingActivityIndicator.stopAnimating()
                        self.categoryCollectionView.reloadData()
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.loadGenresAsync()
                }
            }
        }
    }
    
    func loadfirstReleasesAsync(amount: Int) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            //do shit in async
            if let ids = MangaUpdatesAPI.getLatestReleasesIds() {
                //notify main thread that async method has finished
                DispatchQueue.main.async {
                    self.ids = ids
                    DispatchQueue.global(qos: .userInitiated).async {
                        for mangaId in self.ids.dropLast(self.ids.count-amount){
                            if let manga = MangaUpdatesAPI.getMangaWithId(id: mangaId){
                                DispatchQueue.main.async {
                                    self.mangaCoverItems.append((manga.id, manga.title ,manga.image))
                                    self.releaseCoversLoadingActivityIndicator.stopAnimating()
                                    self.mangaCoverCollectionView.reloadData()
                                    if(self.mangaCoverItems.count % self.batchSize==0){
                                        self.coversAreLoading = false
                                    }
                                }
                            }
                        }
                    }
                }
            }else{
                DispatchQueue.main.async {
                    self.loadfirstReleasesAsync(amount: amount)
                }
            }
        }
    }
    
    func startLoadingOtherReleasesAfter(amount : Int) {
        self.coversAreLoading = true
        let dropFirst = self.ids.dropFirst(amount)
        let dropLast = dropFirst.dropLast(dropFirst.count-batchSize)
        for mangaId in dropLast{
            DispatchQueue.global(qos: .background).async {
                if let manga = MangaUpdatesAPI.getMangaWithId(id: mangaId) {
                    DispatchQueue.main.async {
                        self.mangaCoverItems.append((manga.id, manga.title ,manga.image))
                        self.mangaCoverCollectionView.reloadData()
                        if(self.mangaCoverItems.count % self.batchSize==0){
                            self.coversAreLoading = false
                        }
                    }
                }
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let availableHeightForCovers = organiserView.bounds.size.height - categorysHeight * 4
        if (availableHeightForCovers < CGFloat.init(coverHeight)) {
            mangaCoverCollectionHeight.constant = availableHeightForCovers
            coverHeight = availableHeightForCovers
            coverWidth = coverHeight / 4 * 3
        }else {
            findIdealProportionsWith(availableSpace: availableHeightForCovers)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
            case "advancedSearchSegue":
                let destination = segue.destination as! AdvancedSearchViewController
                destination.genres = genreItems.map({($0.genre, 0)})
            case "openDetailFromHomeSegue":
                let destination = segue.destination as! MangaDetailViewContainerController
                let index = mangaCoverCollectionView.indexPathsForSelectedItems!.first!.item
                destination.mangaId = mangaCoverItems[index].id
                destination.mangaCoverUrl = mangaCoverItems[index].image
            case "showGenreMangas":
                let destination = segue.destination as! MangaSearchResultsViewController
                let index = categoryCollectionView.indexPathsForSelectedItems!.first!.row
                destination.originalSearchUrl = genreItems[index].url
            case "searchByTitleSegue":
                //TODO checken op niet toelaatbare karakters in zoekstring
                let destination = segue.destination as! MangaSearchResultsViewController
                destination.originalSearchUrl = MangaUpdatesURLBuilder.init().searchTitle(searchBarUITextField.text!).resultsPerPage(amount: 50).getUrl()
            default:
                break
        }
    }
    
    
    func findIdealProportionsWith(availableSpace space : CGFloat) {
        let rows = calculateRows(space, coverHeight)
        print(calculateRows(space, CGFloat.init(coverMinHeight)))
        if(calculateRows(space, CGFloat.init(coverMinHeight)) > rows){
            var testHeight = coverHeight
            while (calculateRows(space, testHeight) < rows) {
                testHeight = testHeight - 1
            }
            coverHeight = testHeight
            coverWidth = calculateWidthWithRatioAnd(height: coverHeight)
            mangaCoverCollectionHeight.constant = space
        }else {
            var testHeight = coverHeight
            while(testHeight <= CGFloat.init(coverMaxHeight) && calculateExcess(space, testHeight) > 0){
                testHeight = testHeight + 1
            }
            coverHeight = testHeight
            coverWidth = calculateWidthWithRatioAnd(height: coverHeight)
            mangaCoverCollectionHeight.constant = space - calculateExcess(space, coverHeight)
        }
    }
    
    private func calculateExcess(_ space: CGFloat, _ coverHeight: CGFloat) -> CGFloat{
        return space.truncatingRemainder(dividingBy: coverHeight)
    }
    
    private func calculateRows(_ space: CGFloat, _ coverHeight: CGFloat ) -> Int {
        return Int.init((space - calculateExcess(space, coverHeight)).divided(by: coverHeight))
    }
    
    private func calculateWidthWithRatioAnd(height: CGFloat) -> CGFloat {
        return height / 353 * 250
    }
    
    
}

// MARK: - UICollectionViewDataSource protocol

extension HomeViewController : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout{
    
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //if it is the cover collection
        if(collectionView == mangaCoverCollectionView) {
            //only show the loading cover if there are already some covers loaded
            if(mangaCoverItems.count > 0) {
                return self.mangaCoverItems.count+1
            }else{
                return 0
            }
            //if it is the genrecollection
        }else if(collectionView == categoryCollectionView){
            return self.genreItems.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if(collectionView == mangaCoverCollectionView){
            if(mangaCoverItems.count != ids.count){
                if(coversAreLoading == false && indexPath.row > mangaCoverItems.count - 5){
                    startLoadingOtherReleasesAfter(amount: mangaCoverItems.count)
                }
            }
        }
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if(collectionView == mangaCoverCollectionView) {
            if(indexPath.row != mangaCoverItems.count) {
                // get a reference to our storyboard cell
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierCoverCell, for: indexPath as IndexPath) as! MangaCoverViewCell
                // fill cell with appropriate data
                let data = mangaCoverItems[indexPath.item]
                if data.image == "" {
                    cell.mangacover.image = UIImage.init(named: "loading.jpg")
                } else{
                    cell.mangacover.sd_setImage(with: URL.init(string: data.image), placeholderImage: UIImage.init(named: "loading.jpg"))
                }
                cell.title.attributedText = NSAttributedString.init(string: data.title, attributes: strokeAttributes)
                return cell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierReleasesLoading, for: indexPath as IndexPath) as! ReleaseCoverLoadingViewCell
                cell.activityLoadingIndicator.startAnimating()
                return cell
            }
            //genreCollectionView
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierCategoryCell, for: indexPath as IndexPath) as! MangaCategoryViewCell
            cell.categoryName.text = self.genreItems[indexPath.item].genre
            return cell
        }
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView === mangaCoverCollectionView) {
            return CGSize.init(width: CGFloat.init(coverWidth), height: CGFloat.init(coverHeight))
        }else {
            return CGSize.init(width: collectionView.bounds.size.width/2-10, height: CGFloat.init(45))
        }
    }

}
