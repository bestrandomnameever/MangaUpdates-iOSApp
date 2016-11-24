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
    var genreItems = [("Action", "https://mangaupdates.com/series.html?genre=Action"), ("Adult", "https://mangaupdates.com/series.html?genre=Adult"), ("Adventure", "https://mangaupdates.com/series.html?genre=Adventure"), ("Comedy", "https://mangaupdates.com/series.html?genre=Comedy"), ("Doujinshi", "https://mangaupdates.com/series.html?genre=Doujinshi"), ("Drama", "https://mangaupdates.com/series.html?genre=Drama"), ("Ecchi", "https://mangaupdates.com/series.html?genre=Ecchi"), ("Fantasy", "https://mangaupdates.com/series.html?genre=Fantasy"), ("Gender Bender", "https://mangaupdates.com/series.html?genre=Gender Bender"), ("Harem", "https://mangaupdates.com/series.html?genre=Harem"), ("Hentai", "https://mangaupdates.com/series.html?genre=Hentai"), ("Historical", "https://mangaupdates.com/series.html?genre=Historical"), ("Horror", "https://mangaupdates.com/series.html?genre=Horror"), ("Josei", "https://mangaupdates.com/series.html?genre=Josei"), ("Lolicon", "https://mangaupdates.com/series.html?genre=Lolicon"), ("Martial Arts", "https://mangaupdates.com/series.html?genre=Martial Arts"), ("Mature", "https://mangaupdates.com/series.html?genre=Mature"), ("Mecha", "https://mangaupdates.com/series.html?genre=Mecha"), ("Mystery", "https://mangaupdates.com/series.html?genre=Mystery"), ("Psychological", "https://mangaupdates.com/series.html?genre=Psychological"), ("Romance", "https://mangaupdates.com/series.html?genre=Romance"), ("School Life", "https://mangaupdates.com/series.html?genre=School Life"), ("Sci-fi", "https://mangaupdates.com/series.html?genre=Sci-fi"), ("Seinen", "https://mangaupdates.com/series.html?genre=Seinen"), ("Shotacon", "https://mangaupdates.com/series.html?genre=Shotacon"), ("Shoujo", "https://mangaupdates.com/series.html?genre=Shoujo"), ("Shoujo Ai", "https://mangaupdates.com/series.html?genre=Shoujo Ai"), ("Shounen", "https://mangaupdates.com/series.html?genre=Shounen"), ("Shounen Ai", "https://mangaupdates.com/series.html?genre=Shounen Ai"), ("Slice of Life", "https://mangaupdates.com/series.html?genre=Slice of Life"), ("Smut", "https://mangaupdates.com/series.html?genre=Smut"), ("Sports", "https://mangaupdates.com/series.html?genre=Sports"), ("Supernatural", "https://mangaupdates.com/series.html?genre=Supernatural"), ("Tragedy", "https://mangaupdates.com/series.html?genre=Tragedy"), ("Yaoi", "https://mangaupdates.com/series.html?genre=Yaoi"), ("Yuri", "https://mangaupdates.com/series.html?genre=Yuri")]
    var mangaCoverItems : [(String, String)] = []
    //var mangaCoverItems = [UIImage(named: "loading.jpg"),UIImage(named: "loading.jpg"),UIImage(named: "loading.jpg"),UIImage(named: "loading.jpg"),UIImage(named: "loading.jpg")]
    let strokeAttributes = [
        NSStrokeColorAttributeName : UIColor.black,
        NSForegroundColorAttributeName : UIColor.white,
        NSStrokeWidthAttributeName: -2,
        NSFontAttributeName : UIFont.boldSystemFont(ofSize: 22)
    ] as [String : Any]
    
    // MARK: - Methods
    
    override func viewDidLoad() {
        
        DispatchQueue.global(qos: .userInitiated).async {
            //do shit in async
            if let ids = MangaUpdatesAPI.getLatestReleasesIds() {
                self.ids = ids
            }
            //notify main thread that async method has finished
            DispatchQueue.main.async {
                self.startLoadingOtherReleases()
            }
        }
    }
    
    func startLoadingOtherReleases() {
        for mangaId in self.ids{
            DispatchQueue.global(qos: .default).async {
                let manga = MangaUpdatesAPI.getMangaWithId(id: mangaId)
                self.mangaCoverItems.append((manga!.title ,manga!.image))
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
        case "searchSegue":
            let destination = segue.destination as! MangaSearchResultsViewController
            destination.searchUrl = uiSearchBar.text
        case "openDetailFromHomeSegue":
            let destination = segue.destination as! MangaDetailViewController
            let index = mangaCoverCollectionView.indexPathsForSelectedItems!.first!.row
            destination.image = mangaCoverItems[index].1
            destination.viewTitle = mangaCoverItems[index].0
        case "showGenreMangas":
            let destination = segue.destination as! MangaSearchResultsViewController
            let index = categoryCollectionView.indexPathsForSelectedItems!.first!.row
            destination.searchUrl = genreItems[index].1
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
        if(collectionView == mangaCoverCollectionView) {
            return self.mangaCoverItems.count
        }else if(collectionView == categoryCollectionView){
            return self.genreItems.count
        }
        return 0
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if(collectionView == mangaCoverCollectionView) {
            // get a reference to our storyboard cell
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifierCoverCell, for: indexPath as IndexPath) as! MangaCoverViewCell
            // fill cell with appropriate data
            let data = mangaCoverItems[indexPath.item]
            if data.1 == "" {
                cell.mangacover.image = UIImage.init(named: "loading.jpg")
            } else{
                cell.mangacover.sd_setImage(with: URL.init(string: data.1), placeholderImage: UIImage.init(named: "loading.jpg"))
            }
            cell.title.attributedText = NSAttributedString.init(string: data.0, attributes: strokeAttributes)
            return cell
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

extension HomeViewController : UISearchBarDelegate {
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        searchBar.becomeFirstResponder()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.endEditing(true)
    }

}
