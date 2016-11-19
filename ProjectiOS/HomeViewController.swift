//
//  HomeViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 19/11/2016.
//  Copyright © 2016 Anthony. All rights reserved.
//

import UIKit

class HomeViewController : UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    let reuseIdentifier = "mangaCoverCell"
    var items = [UIImage(named: "GECover"),UIImage(named: "nisekoi.jpg"),UIImage(named: "aracna.jpg"),UIImage(named: "blueExorcist.jpg"),UIImage(named: "kimiNoIruMachi.jpg")]
    
    // MARK: - UICollectionViewDataSource protocol
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.items.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! MangaCoverViewCell
        
        // Use the outlet in our custom class to get a reference to the UILabel in the cell
        cell.mangacover.image = self.items[indexPath.item]
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
    
    //func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //
    //}
    
}
