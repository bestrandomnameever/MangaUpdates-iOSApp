//
//  CoverImagePopOverViewController.swift
//  ProjectiOS
//
//  Created by Anthony on 28/02/2017.
//  Copyright © 2017 Anthony. All rights reserved.
//

import UIKit

class CoverImagePopOverViewController: UIViewController {

    @IBOutlet weak var largeCoverImage: UIImageView!
    var mangaCoverUrl : String!
    
    
    @IBAction func closePopOver(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        largeCoverImage.sd_setImage(with: URL.init(string: self.mangaCoverUrl))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
