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
    @IBOutlet weak var searchButton: UIButton!
    
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
    let coverMinHeight = 220
    var coverHeight = 0
    var coverWidth = 0
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
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        mangaCoverCollectionView.collectionViewLayout.invalidateLayout()
        mangaCoverCollectionView.reloadData()
        categoryCollectionView.collectionViewLayout.invalidateLayout()
        categoryCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        findIdealProportionsWith()
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
    
    
    @IBAction func onReturnPressedSearchField(_ sender: Any) {
        view.endEditing(true)
        searchButton.sendActions(for: .touchUpInside)
        searchBarUITextField.text = ""
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
            destination.pageTitle = genreItems[index].genre
        case "searchByTitleSegue":
            //TODO checken op niet toelaatbare karakters in zoekstring
            let destination = segue.destination as! MangaSearchResultsViewController
            destination.originalSearchUrl = MangaUpdatesURLBuilder.init().searchTitle(searchBarUITextField.text!).resultsPerPage(amount: 50).getUrl()
            destination.pageTitle = searchBarUITextField.text!.lowercased().capitalized
        default:
            break
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
    
    
    func findIdealProportionsWith() {
        let space = Int(mangaCoverCollectionView.bounds.height)
        let rows = calculateRows(space, coverMinHeight)
        if(space < coverMinHeight){
            coverHeight = space
        }else{
            let excess = calculateExcess(space, coverMinHeight)
            coverHeight = coverMinHeight + ((excess - (excess % rows)) / rows)
        }
        coverWidth = Int.init(round(Double(coverHeight/4*3)))
    }
    
    private func calculateExcess(_ space: Int, _ coverHeight: Int) -> Int{
        return space % coverHeight
    }
    
    private func calculateRows(_ space: Int, _ coverHeight: Int ) -> Int {
        return (space - calculateExcess(space, coverHeight)) / coverHeight
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
            print(coverHeight)
            return CGSize.init(width: coverWidth, height: coverHeight)
        }else {
            return CGSize.init(width: 170, height: 45)
        }
    }

}


/*
 credit = http://stackoverflow.com/questions/24126678/close-ios-keyboard-by-touching-anywhere-using-swift
 */
extension UIViewController{
    func hideKeyboardWhenTappedAround(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
}
