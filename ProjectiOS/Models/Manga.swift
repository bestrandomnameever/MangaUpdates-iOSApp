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
    let description : String
    let image : String
    let author : String
    let artist : String
    let type : String
    let genres : [String]
    var categories : [String]
    let score : String
    var recommendationsIds : [String]
    var categoryRecommendationsIds : [String]
    var relatedSeriesIds : [String]
    var alternateNames : [String]
    var votes : [(Int, Int)]
    
    
    
    init(id : String, title : String, description : String ,image : String, author : String, artist : String, type : String, genres : [String], categories : [String], score : String, recommendationsIds : [String], categoryRecommendationsIds : [String], relatedSeriesIds: [String], alternateNames: [String], votes: [(Int, Int)]) {
        self.id = id
        self.title = title
        self.description = description
        self.image = image
        self.author = author
        self.artist = artist
        self.type = type
        self.genres = genres
        self.categories = categories
        self.score = score
        self.recommendationsIds = recommendationsIds
        self.categoryRecommendationsIds = categoryRecommendationsIds
        self.relatedSeriesIds = relatedSeriesIds
        self.alternateNames = alternateNames
        self.votes = votes
    }
}
