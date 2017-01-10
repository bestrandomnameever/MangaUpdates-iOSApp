//
//  MangaDetailViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 20/11/2016.
//  Copyright © 2016 Anthony. All rights reserved.
//

import UIKit

class MangaDetailViewController: UIViewController {
    
    var manga : Manga!
    
    @IBOutlet weak var uiTitle: UINavigationItem!
    @IBOutlet weak var coverUIImageView: UIImageView!
    @IBOutlet weak var authorUILabel: UILabel!
    @IBOutlet weak var artistUILabel: UILabel!
    @IBOutlet weak var typeUILabel: UILabel!
    @IBOutlet weak var genresUILabel: UILabel!
    
    override func viewDidLoad() {
        uiTitle.title = manga.title
        coverUIImageView.sd_setImage(with: URL.init(string: manga.image))
        authorUILabel.text = manga.author
        artistUILabel.text = manga.artist
        genresUILabel.text = manga.genres.joined(separator: ", ")
        typeUILabel.text = manga.type
        print(manga.categories)
        print(manga.description)
        print(manga.recommendationsIds)
        print(manga.categoryRecommendationsIds)
    }
}
