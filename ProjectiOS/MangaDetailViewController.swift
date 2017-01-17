//
//  MangaDetailViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 20/11/2016.
//  Copyright © 2016 Anthony. All rights reserved.
//

import UIKit

class MangaDetailViewController: UIViewController {
    
    //var manga : Manga?
    var mangaId : String!
    var mangaCoverUrl : String!
    
    @IBOutlet weak var uiTitle: UINavigationItem!
    @IBOutlet weak var coverUIImageView: UIImageView!
    @IBOutlet weak var authorUILabel: UILabel!
    @IBOutlet weak var artistUILabel: UILabel!
    @IBOutlet weak var typeUILabel: UILabel!
    @IBOutlet weak var genresUILabel: UILabel!
    
    @IBOutlet weak var detailsLoadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var blurredImageView: UIImageView!
    
    override func viewDidLoad() {
        blurredImageView.superview!.bringSubview(toFront: blurredImageView)
        detailsLoadingActivityIndicator.superview!.bringSubview(toFront: detailsLoadingActivityIndicator)
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurredImageView.addSubview(blurEffectView)
        blurredImageView.sd_setImage(with: URL.init(string: mangaCoverUrl))
        
        DispatchQueue.global(qos: .userInitiated).async {
            if let mangaOptional = MangaUpdatesAPI.getMangaWithId(id: self.mangaId){
                DispatchQueue.main.async {
                    self.detailsLoadingActivityIndicator.stopAnimating()
                    self.blurredImageView.superview!.sendSubview(toBack: self.blurredImageView)
                    self.uiTitle.title = mangaOptional.title
                    self.coverUIImageView.sd_setImage(with: URL.init(string: self.mangaCoverUrl))
                    self.authorUILabel.text = mangaOptional.author
                    self.artistUILabel.text = mangaOptional.artist
                    self.genresUILabel.text = mangaOptional.genres.joined(separator: ", ")
                    self.typeUILabel.text = mangaOptional.type
                }
            }
        }
    }
}
