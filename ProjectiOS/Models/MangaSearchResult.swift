//
//  MangaSearchResult.swift
//  ProjectiOS
//
//  Created by Anthony on 17/01/2017.
//  Copyright © 2017 Anthony. All rights reserved.
//


class MangaSearchResult {
    
    let id : String
    let title : String
    let image : String
    let author : String
    let genres : [String]
    let score : String
    
    init(id: String, title: String, image: String, author: String, genres: [String], score: String) {
        self.id = id
        self.title = title
        self.image = image
        self.author = author
        self.genres = genres
        self.score = score
    }
}
