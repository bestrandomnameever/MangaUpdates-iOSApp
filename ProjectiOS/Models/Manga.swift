//
//  Manga.swift
//  ProjectiOS
//
//  Created by Anthony on 21/11/2016.
//  Copyright © 2016 Anthony. All rights reserved.
//

import UIKit

class Manga {
    
    let id : String
    let title : String
    let image : String
    let author : String
    let artist : String
    let type : String
    var categories : [String]?
    var recommendations : [Manga]?
    var categoryRecommendations : [Manga]?
    let genres : [String]
    
    
    
    init(id : String, title : String, image : String, author : String, artist : String, type : String, genres : [String]) {
        self.id = id
        self.title = title
        self.image = image
        self.author = author
        self.artist = artist
        self.type = type
        self.genres = genres
    }

}
