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
    
    @IBAction func showAlternateNames(_ sender: Any) {
        let alert = UIAlertController.init(title: "Alternate names", message: manga.alternateNames.joined(separator: "\r\n"), preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Close", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var coverUIImageView: UIImageView!
    @IBOutlet weak var authorUILabel: UILabel!
    @IBOutlet weak var artistUILabel: UILabel!
    @IBOutlet weak var typeUILabel: UILabel!
    @IBOutlet weak var genresUILabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var scoreLabel: UILabel!
    
    override func viewDidLoad() {
        self.titleButton.setTitle(manga.title, for: .normal)
        self.coverUIImageView.sd_setImage(with: URL.init(string: self.mangaCoverUrl))
        self.authorUILabel.text = manga.author
        self.artistUILabel.text = manga.artist
        self.genresUILabel.text = manga.genres.joined(separator: ", ")
        self.typeUILabel.text = manga.type
        self.descriptionTextView.text = manga.description
        self.scoreLabel.text = manga.score + "/10"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "showPopOverCover":
            let destination = segue.destination as! CoverImagePopOverViewController
            destination.mangaCoverUrl = mangaCoverUrl
            break
        case "showScoresPopOver":
            let destination = segue.destination as! ScoresPopOverViewController
            destination.votes = manga.votes
            break
        default:
            break
        }
    }
    
}
