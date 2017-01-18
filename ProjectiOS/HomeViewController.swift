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
    @IBOutlet weak var uiSearchBar: UISearchBar!
    
    let spacingTwoCollectionViews = CGFloat.init(2)
    let coverMinHeight = 230
    var coverHeight = CGFloat.init(250)
    let coverMaxHeight = 280
    var coverWidth : CGFloat!
    let categorysHeight = CGFloat.init(45)
    var ids : [String] = []
    let initialLoadReleases = 7
    let totalReleasesShownMinusInitial = 30
    
    let reuseIdentifierCoverCell = "mangaCoverCell"
    let reuseIdentifierCategoryCell = "categoryCell"
    let reuseIdentifierReleasesLoading = "releaseCoverLoadingCell"
    var genreItems : [(String,URL)] = []
    var mangaCoverItems : [(id: String ,title: String, image: String)] = []
    let strokeAttributes = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSStrokeWidthAttributeName: -2,
        NSFontAttributeName : UIFont.boldSystemFont(ofSize: 22)
    ] as [String : Any]
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let genresAndUrls = MangaUpdatesAPI.getGenresAndUrls() {
                self.genreItems = genresAndUrls
            }
            DispatchQueue.main.async {
                self.genreLoadingActivityIndicator.stopAnimating()
                self.categoryCollectionView.reloadData()
            }
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            //do shit in async
            if let ids = MangaUpdatesAPI.getLatestReleasesIds() {
                self.ids = ids
            }
            //notify main thread that async method has finished
            DispatchQueue.main.async {
                self.loadfirstReleases(amount: 50)
            }
        }
    }
    
    func loadfirstReleases(amount: Int) {
        DispatchQueue.global(qos: .userInitiated).async {
                for mangaId in self.ids.dropLast(self.ids.count-amount){
                    //TODO crasht soms op random id die naar een correcte manga wijst, concurrency?
                    if let manga = MangaUpdatesAPI.getMangaWithId(id: mangaId){
                        self.mangaCoverItems.append((manga.id, manga.title ,manga.image))
                    }
                    DispatchQueue.main.async {
                        self.releaseCoversLoadingActivityIndicator.stopAnimating()
                        self.mangaCoverCollectionView.reloadData()
                        //self.startLoadingOtherReleasesAfter(amount: amount)
                    }
                }
        }
    }
    
    func startLoadingOtherReleasesAfter(amount : Int) {
        for mangaId in self.ids.dropFirst(amount){
            DispatchQueue.global(qos: .background).async {
                let manga = MangaUpdatesAPI.getMangaWithId(id: mangaId)
                self.mangaCoverItems.append((manga!.id, manga!.title ,manga!.image))
                DispatchQueue.main.async {
                    self.mangaCoverCollectionView.reloadData()
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
                destination.genres = genreItems.map({($0.0, 0)})
//            case "searchSegue":
//                let destination = segue.destination as! MangaSearchResultsViewController
//                destination.searchUrl = uiSearchBar.text
            case "openDetailFromHomeSegue":
                let destination = segue.destination as! MangaDetailViewController
                let index = mangaCoverCollectionView.indexPathsForSelectedItems!.first!.item
                //destination.manga = MangaUpdatesAPI.getMangaWithId(id: mangaCoverItems[index].0)!
                destination.mangaId = mangaCoverItems[index].0
                destination.mangaCoverUrl = mangaCoverItems[index].image
            case "showGenreMangas":
                let destination = segue.destination as! MangaSearchResultsViewController
                let index = categoryCollectionView.indexPathsForSelectedItems!.first!.row
                destination.originalSearchUrl = genreItems[index].1
            case "searchByTitleSegue":
                let destination = segue.destination as! MangaSearchResultsViewController
                destination.originalSearchUrl = MangaUpdatesURLBuilder.init().searchTitle(searchBarUITextField.text!).getUrl()
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
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if(collectionView == mangaCoverCollectionView) {
            if(indexPath.row != mangaCoverItems.count) {
                // get a reference to our storyboard cell
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierCoverCell, for: indexPath as IndexPath) as! MangaCoverViewCell
                // fill cell with appropriate data
                let data = mangaCoverItems[indexPath.item]
                if data.1 == "" {
                    cell.mangacover.image = UIImage.init(named: "loading.jpg")
                } else{
                    cell.mangacover.sd_setImage(with: URL.init(string: data.2), placeholderImage: UIImage.init(named: "loading.jpg"))
                }
                cell.title.attributedText = NSAttributedString.init(string: data.1, attributes: strokeAttributes)
                return cell
            }else{
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierReleasesLoading, for: indexPath as IndexPath) as! ReleaseCoverLoadingViewCell
                cell.activityLoadingIndicator.startAnimating()
                return cell
            }
        }else if(collectionView == categoryCollectionView) {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierCategoryCell, for: indexPath as IndexPath) as! MangaCategoryViewCell
            cell.categoryName.text = self.genreItems[indexPath.item].0
            cell.categoryName.textAlignment = NSTextAlignment.center
            return cell
        }
        
        return UICollectionViewCell.init()
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        
        
        if(collectionView == mangaCoverCollectionView) {
            print("You selected cell #\(indexPath.item) from the mangaCoverUICollection")
        }else if(collectionView == categoryCollectionView) {
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(collectionView === mangaCoverCollectionView) {
            return CGSize.init(width: CGFloat.init(coverWidth), height: CGFloat.init(coverHeight))
        }else if(collectionView === categoryCollectionView) {
            return CGSize.init(width: collectionView.bounds.size.width/2-10, height: CGFloat.init(45))
        }
        return CGSize.init()
    }

}

//extension HomeViewController : UITextFieldDelegate {
//    
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//        searchBar.setShowsCancelButton(true, animated: true)
//        searchBar.becomeFirstResponder()
//    }
//    
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.setShowsCancelButton(false, animated: true)
//        searchBar.endEditing(true)
//    }
//    
//    
//
//}
