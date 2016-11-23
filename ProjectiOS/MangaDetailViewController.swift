//
//  MangaDetailViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 20/11/2016.
//  Copyright © 2016 Anthony. All rights reserved.
//

import UIKit

class MangaDetailViewController: UIViewController {
    
    var image : String?
    var viewTitle : String?
    
    @IBOutlet weak var uiTitle: UINavigationItem!
    
    @IBOutlet weak var coverUIImageView: UIImageView!
    override func viewDidLoad() {
        uiTitle.title = viewTitle!
        coverUIImageView.sd_setImage(with: URL.init(string: image!), placeholderImage: UIImage.init(named: "loading.jpg"))
    }
}
