//
//  MangaUpdatesAPI.swift
//  ProjectiOS
//
//  Created by Anthony on 22/11/2016.
//  Copyright © 2016 Anthony. All rights reserved.
//
import UIKit
import Alamofire
import Kanna
import SDWebImage

class MangaUpdatesAPI {
    static let BaseUrl = "https://mangaupdates.com/"
    static let ReleaseUrlExtension = "releases.html"
    static let SeriesWithIdUrlExtension = "series.html?id="
    static let SearchTitleExtension = "series.html?stype=utf8title&search="
    static let genresExtension = "genres.html"
    static let genreSearchExtension = "series.html?genre="
    
    init() {
        
    }
    
    static func getLatestReleasesIds() -> [String]? {
        let url = URL.init(string: BaseUrl + ReleaseUrlExtension)
        if let doc = Kanna.HTML(url: url!, encoding: .utf8) {
            return doc.xpath("//a[@title='Series Info']").flatMap({$0["href"]!.substring(from: $0["href"]!.index($0["href"]!.startIndex, offsetBy: 43))})
        }
        return nil
    }
    
    static func getMangaWithId(id : String) -> Manga? {
        let url = URL.init(string: BaseUrl + SeriesWithIdUrlExtension + id)
        print(url!)
        if let doc = Kanna.HTML(url: url!, encoding: .isoLatin1) {
            let title = doc.xpath("//span[@class='releasestitle tabletitle']").first!.text
            var image = doc.xpath("//center/img").first?["src"]
            if image == nil {
                image = ""
            }
            let author = doc.xpath("//div[@class='sCat'][b='Author(s)']/following-sibling::*[1]").first!.text
            let artist = doc.xpath("//div[@class='sCat'][b='Artist(s)']/following-sibling::*[1]").first!.text
            let type = doc.xpath("//div[@class='sCat'][b='Type']/following-sibling::*[1]").first!.text
            let categories = doc.xpath("//div[@class='sCat'][b='Categories']/following-sibling::*[1]//li/a").flatMap({$0.text})
            let genres = Array.init(doc.xpath("//div[@class='sCat'][b='Genre']/following-sibling::*[1]//u").flatMap({$0.text}).dropLast())
            let manga = Manga.init(id: id, title: title!, image: image!, author: author!, artist: artist!, type: type!, genres: genres)
            manga.categories = categories
            return manga
        }
        return nil
    }
    
    static func getGenresAndUrls() -> [(String, String)]? {
        let url = URL.init(string: BaseUrl + genresExtension)
        var genresAndUrls : [(String, String)]? = Array.init()
        if let doc = Kanna.HTML(url: url!, encoding: .isoLatin1) {
            let genres = doc.xpath("//td[@class='releasestitle']/b")
            for genre in genres {
                var genreAndUrlTuple = (name: "", url: "")
                genreAndUrlTuple.name = genre.text!
                genreAndUrlTuple.url = BaseUrl + genreSearchExtension + genreAndUrlTuple.name
                genresAndUrls?.append(genreAndUrlTuple)
            }
        }
        return genresAndUrls
    }
}
