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
    var mangaCoverUrl : String!
    @IBOutlet weak var blurredImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurredImageView.addSubview(blurEffectView)
        blurredImageView.sd_setImage(with: URL.init(string: mangaCoverUrl))
    }
    
}
