//
//  MangaDetailViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 20/11/2016.
//  Copyright © 2016 Anthony. All rights reserved.
//

import UIKit

class MangaDetailViewController: UIViewController {
    
    var image : UIImage?
    
    @IBOutlet weak var uiTitle: UINavigationItem!
    
    @IBOutlet weak var coverUIImageView: UIImageView!
    override func viewDidLoad() {
        coverUIImageView.image = image!
    }
}
