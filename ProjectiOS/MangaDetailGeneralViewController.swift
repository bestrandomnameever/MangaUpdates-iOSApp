//
//  MangaDetailViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 20/11/2016.
//  Copyright © 2016 Anthony. All rights reserved.
//

import UIKit

class MangaDetailGeneralViewController: UIViewController {
    
    var mangaId : String!
    var manga : Manga!
    var mangaCoverUrl : String!
    
    @IBOutlet weak var uiTitle: UINavigationItem!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var coverUIImageView: UIImageView!
    @IBOutlet weak var authorUILabel: UILabel!
    @IBOutlet weak var artistUILabel: UILabel!
    @IBOutlet weak var typeUILabel: UILabel!
    @IBOutlet weak var genresUILabel: UILabel!
    
    override func viewDidLoad() {
        self.titleLabel.text = manga.title
        self.coverUIImageView.sd_setImage(with: URL.init(string: self.mangaCoverUrl))
        self.authorUILabel.text = manga.author
        self.artistUILabel.text = manga.artist
        self.genresUILabel.text = manga.genres.joined(separator: ", ")
        self.typeUILabel.text = manga.type
    }
}
