//
//  MangaUpdatesAPI.swift
//  ProjectiOS
//
//  Created by Anthony on 22/11/2016.
//  Copyright © 2016 Anthony. All rights reserved.
//
import UIKit
import Kanna
import SDWebImage

class MangaUpdatesAPI {
    
    static func getLatestReleasesIds() -> [String]? {
        let url = MangaUpdatesURLBuilder.init().releasesURL()
        if let doc = Kanna.HTML(url: url, encoding: .isoLatin1) {
            return doc.xpath("//a[@title='Series Info']").flatMap({$0["href"]!.components(separatedBy: "id=")[1]})
        }
        return nil
    }
    
    static func getMangaWithId(id : String) -> Manga? {
        let url = MangaUpdatesURLBuilder.init().getMangaURLForId(id: id)
        if let doc = Kanna.HTML(url: url, encoding: .isoLatin1) {
            let title = doc.xpath("//span[@class='releasestitle tabletitle']").first!.text
            let description = doc.xpath("//div[@class='sCat'][b='Description']/following-sibling::*[1]").first!.text
            var image = doc.xpath("//center/img").first?["src"]
            if image == nil {
                image = ""
            }
            let author = doc.xpath("//div[@class='sCat'][b='Author(s)']/following-sibling::*[1]").first!.text
            let artist = doc.xpath("//div[@class='sCat'][b='Artist(s)']/following-sibling::*[1]").first!.text
            let type = doc.xpath("//div[@class='sCat'][b='Type']/following-sibling::*[1]").first!.text
            let categories = doc.xpath("//li[@class='tag_normal']/a[@rel='nofollow']").flatMap({$0.text})
            let genres = Array.init(doc.xpath("//div[@class='sCat'][b='Genre']/following-sibling::*[1]//u").flatMap({$0.text}).dropLast())
            let recommendations = doc.xpath("//div[@class='sCat'][b='Recommendations']/following-sibling::*[1]//a").filter({!$0["href"]!.contains("javascript")}).flatMap({$0["href"]!.components(separatedBy: "id=")[1]})
            let categoryRecommendations = doc.xpath("//div[@class='sCat'][b='Category Recommendations']/following-sibling::*[1]//a").flatMap({$0["href"]!.components(separatedBy: "id=")[1]})
            let score : String
            if let scoreOptional = doc.xpath("//div[@class='sContent' and contains(text(),'Average')]/b").first {
                score = scoreOptional.text!
            }else {
                score = "-"
            }
            var alternateNames : [String]
            if let alternateNamesOptional = doc.xpath("//div[@class='sCat'][b='Associated Names']/following-sibling::*[1]").first?.innerHTML?.components(separatedBy: "<br>").dropLast() {
                alternateNames = Array.init(alternateNamesOptional)
            }else{
                alternateNames = ["No alternate names"]
            }
            let manga = Manga.init(id: id, title: title!, description: description! ,image: image!, author: author!, artist: artist!, type: type!, genres: genres, categories: categories,score: score, recommendationsIds: recommendations, categoryRecommendationsIds: categoryRecommendations, alternateNames: alternateNames
            )
            return manga
        }
        return nil
    }
    
    static func getMangaSearchResultWithId(id : String) -> MangaSearchResult? {
        let url = MangaUpdatesURLBuilder.init().getMangaURLForId(id: id)
        if let doc = Kanna.HTML(url: url, encoding: .isoLatin1) {
            let title = doc.xpath("//span[@class='releasestitle tabletitle']").first!.text!
            var image = "http://otakumeme.com/wp-content/uploads/2013/01/never-fap-alone-its-dangerous_o_501668.jpg"
            if let imageOptional = doc.xpath("//center/img").first?["src"] {
                image = imageOptional
            }
            var author = "-"
            if let authorOptional = doc.xpath("//div[@class='sCat'][b='Author(s)']/following-sibling::*[1]").first?.text {
                author = authorOptional
            }
            let genres = Array.init(doc.xpath("//div[@class='sCat'][b='Genre']/following-sibling::*[1]//u").flatMap({$0.text}).dropLast())
            let score : String
            if let scoreOptional = doc.xpath("//div[@class='sContent' and contains(text(),'Average')]/b").first {
                score = scoreOptional.text!
            }else {
                score = "-"
            }
            let mangaSearchResult = MangaSearchResult.init(id: id, title: title, image: image, author: author, genres: genres, score: score)
            return mangaSearchResult
        }
        return nil
    }
    
    static func getGenresAndUrls() -> [(String, URL)]? {
        let url = URL.init(string: "https://www.mangaupdates.com/genres.html")
        var genresAndUrls : [(String, URL)]? = Array.init()
        if let doc = Kanna.HTML(url: url!, encoding: .isoLatin1) {
            let genres = doc.xpath("//td[@class='releasestitle']/b")
            for genre in genres {
                let genreAndUrlTuple = (name: genre.text!, url: MangaUpdatesURLBuilder.init().includeGenres([genre.text!]).getUrl())
                genresAndUrls?.append(genreAndUrlTuple)
            }
        }
        return genresAndUrls
    }
    
    static func getMangaIdsFor(genreUrl : String) -> (ids: [String], hasNextPage: Bool) {
        let url = URL.init(string: genreUrl)
        return getMangaIdsFrom(searchUrl: url!)
    }
    
    static func getMangaIdsFrom(searchUrl : URL) -> (ids: [String], hasNextPage: Bool) {
        var idsAndBool: ([String],Bool) = ([], false)
        if let doc = Kanna.HTML(url: searchUrl, encoding: .isoLatin1) {
            idsAndBool.0 = doc.xpath("//a[@alt='Series Info']").flatMap({$0["href"]!.components(separatedBy: "id=")[1]})
            if let nextPage = doc.xpath("//a[. = 'Next Page']").first?["href"]! {
                idsAndBool.1 = true
            }else{
                idsAndBool.1 = false
            }
        }
        return idsAndBool
    }
}
