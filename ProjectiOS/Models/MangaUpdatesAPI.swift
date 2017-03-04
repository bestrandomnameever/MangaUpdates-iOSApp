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
import Alamofire

class MangaUpdatesAPI {
    
    static func getLatestReleasesIds(completionHandler:@escaping ([String]?) -> ()) {
        let url = MangaUpdatesURLBuilder.init().releasesURL()
        Alamofire.request(url).response { response in
            if let doc = Kanna.HTML(html: response.data!, encoding: .isoLatin1) {
                completionHandler(doc.xpath("//a[@title='Series Info']").flatMap({$0["href"]!.components(separatedBy: "id=")[1]}))
            }else {
                completionHandler(nil)
            }
        }
    }
    
    
    static func getMangaWithId(id : String, completionHandler:@escaping (Manga?) -> ()) {
        let url = MangaUpdatesURLBuilder.init().getMangaURLForId(id: id)
        Alamofire.request(url).response { response in
            if let doc = Kanna.HTML(html: response.data!, encoding: .isoLatin1) {
                let title = doc.xpath("//span[@class='releasestitle tabletitle']").first!.text
                var alternateNames : [String]
                if let alternateNamesOptional = doc.xpath("//div[@class='sCat'][b='Associated Names']/following-sibling::*[1]").first?.innerHTML?.components(separatedBy: "<br>").dropLast() {
                    alternateNames = Array.init(alternateNamesOptional)
                }else{
                    alternateNames = ["No alternate names"]
                }
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
                let relatedSeries = doc.xpath("//div[@class='sCat'][b='Related Series']/following-sibling::*[1]//a").flatMap({$0["href"]!.components(separatedBy: "id=")[1]})
                let score : String
                
                
                
                if let scoreOptional = doc.xpath("//div[@class='sContent' and contains(text(),'Average')]/b").first {
                    score = scoreOptional.text!
                }else {
                    score = "-"
                }
                var votes : [(score: Int, votes: Int)] = []
                var votesFromWebsite = doc.xpath("//div[@class='sContent' and contains(text(),'Average')]//span").flatMap({$0.text?.components(separatedBy: " ")[1]})
                if votesFromWebsite.count > 0{
                    for index in 0...9{
                        votes.append((10-index, Int.init(votesFromWebsite[index].replacingOccurrences(of: "(", with: ""))!))
                    }
                }
                
                let manga = Manga.init(id: id, title: title!, description: description! ,image: image!, author: author!, artist: artist!, type: type!, genres: genres, categories: categories,score: score, recommendationsIds: recommendations, categoryRecommendationsIds: categoryRecommendations, relatedSeriesIds: relatedSeries, alternateNames: alternateNames, votes: votes
                )
                completionHandler(manga)
            }
            completionHandler(nil)
        }
    }
    
    
    static func getMangaSearchResultWithId(id : String, completionHandler:@escaping (MangaSearchResult?) -> ()) {
        //TODO zorgen dat hij https gebruikt -> zie probleem met cookie en images
        let url = MangaUpdatesURLBuilder.init().getMangaURLForId(id: id)
        Alamofire.request(url).response { response in
            if response.response?.statusCode == 200 {
                if let doc = Kanna.HTML(html: response.data!, encoding: .isoLatin1) {
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
                    completionHandler(mangaSearchResult)
                }else {
                    completionHandler(nil)
                }
            }
        }
    }
    
    
    static func getGenresAndUrls(completionHandler:@escaping ([(String, URL)]?) -> ()) {
        let url = URL.init(string: "https://www.mangaupdates.com/genres.html")
        Alamofire.request(url!).response { response in
            if let doc = Kanna.HTML(html: response.data!, encoding: .isoLatin1) {
                var genresAndUrls : [(String, URL)]? = Array.init()
                let genres = doc.xpath("//td[@class='releasestitle']/b")
                for genre in genres {
                    let genreAndUrlTuple = (name: genre.text!, url: MangaUpdatesURLBuilder.init().includeGenres([genre.text!]).getUrl())
                    genresAndUrls?.append(genreAndUrlTuple)
                }
                completionHandler(genresAndUrls)
            }
            completionHandler(nil)
        }
    }
    
    
    //TODO update naar Alamo
    static func getMangaIdsFor(genreUrl : String, completionHandler:@escaping ([String]?, Bool?) -> ()) {
        let url = URL.init(string: genreUrl)
        return getMangaIdsFrom(searchUrl: url!, completionHandler: completionHandler)
    }
    
    
    //TODO update naar Alamo
    static func getMangaIdsFrom(searchUrl : URL, completionHandler:@escaping ([String]?, Bool?) -> ()) {
//        var idsAndBool: ([String],Bool) = ([], false)
//        if let doc = Kanna.HTML(url: searchUrl, encoding: .isoLatin1) {
//            idsAndBool.0 = doc.xpath("//a[@alt='Series Info']").flatMap({$0["href"]!.components(separatedBy: "id=")[1]})
//            if let nextPage = doc.xpath("//a[. = 'Next Page']").first?["href"]! {
//                idsAndBool.1 = true
//            }else{
//                idsAndBool.1 = false
//            }
//        }
//        return idsAndBool
        Alamofire.request(searchUrl).response{ response in
            if let doc = Kanna.HTML(html: response.data!, encoding: .isoLatin1) {
                var hasNextPage: Bool? = nil
                let ids = doc.xpath("//a[@alt='Series Info']").flatMap({$0["href"]!.components(separatedBy: "id=")[1]})
                if let nextPage = doc.xpath("//a[. = 'Next Page']").first?["href"]! {
                    hasNextPage = true
                }else{
                    hasNextPage = false
                }
                completionHandler(ids, hasNextPage)
            }
            completionHandler(nil,nil)
        }
    }
    
    ////////////////////////
    //User specific
    ///////////////////////
    
    static func logIn(username: String, password: String, completionHandler:@escaping (Bool) -> ()) {
        let parameters = ["act": "login", "username": username, "password": password]
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        Alamofire.request("https://www.mangaupdates.com/login.html", parameters: parameters).response { response in
            if response.response?.statusCode == 200 {
                if let doc = Kanna.HTML(html: response.data!, encoding: .isoLatin1) {
                    if let succes = doc.xpath("//td[contains(@class, 'text') and contains(@class, 'table_content')]").first?.text?.contains("No user found") {
                        if !succes {
                            let username = doc.xpath("//td[contains(@class, 'tab_middle') and contains(., 'Welcome')]").first!.text!.components(separatedBy: " ")[2]
                            UserDefaults.standard.set(username, forKey: "username")
                            completionHandler(true)
                        }else {
                            completionHandler(false)
                        }
                    }else {
                        completionHandler(false)
                    }
                }
            }
        }
    }
    
    
    //TODO afwerken naar niet boolean return
    static func getList (list: UserListType, completionHandler:@escaping (Bool) -> ()) {
        let url = "https://www.mangaupdates.com/mylist.html?list=" + list.rawValue
        Alamofire.request(url).response { response in
            if response.response?.statusCode == 200 {
                if let doc = Kanna.HTML(html: response.data!, encoding: .isoLatin1) {
                    for element in doc.xpath("//tr[contains(@class, 'lrow')]") {
                        let id = element.xpath("td")[1].at_xpath("a")?["href"]?.components(separatedBy: "id=")[1]
                        print(id)
                    }
                }
            }
            completionHandler(true)
        }
    }
    
    static func updateRatingMangaWithId(id: String, rating: String, completionHandler:@escaping (Bool) -> ()) {
        let url = "https://www.mangaupdates.com/ajax/update_rating.php?s=\(id)&r=\(rating)"
        Alamofire.request(url).response { response in
            if let doc = Kanna.HTML(html: response.data!, encoding: .isoLatin1) {
                if doc.body != nil {
                    if let newScore = doc.xpath("//b").first?.innerHTML {
                        print("new score is \(newScore)")
                        completionHandler(true)
                    }else {
                        //invalid score
                        print("Invalid score")
                        completionHandler(false)
                    }
                }else {
                    //No cookie
                    print("No cookie (no authorisation)")
                    completionHandler(false)
                }
            } else{
                //No internet
                print("Something else went wrong, probably internet")
                completionHandler(false)
            }
        }
    }
    
    static func updateChapterProgressMangaWithId(id: String, chapter: String, completionHandler:@escaping (Bool) -> ()) {
        let url = "https://www.mangaupdates.com/ajax/chap_update.php?s=\(id)&set_c=\(chapter)"
        Alamofire.request(url).response { response in
            if let doc = Kanna.HTML(html: response.data!, encoding: .isoLatin1) {
                if doc.body != nil {
                    if let newChapter = doc.xpath("//b")[1].innerHTML {
                        if(newChapter == "c.\(chapter)") {
                            print("new chapter number is \(chapter)")
                            completionHandler(true)
                        }else {
                            //invalid chapter
                            print("invalid chapter, current chapter is \(newChapter)")
                            completionHandler(false)
                        }
                    }
                }else {
                    //No cookie
                    print("No cookie (no authorisation)")
                    completionHandler(false)
                }
            } else{
                //No internet
                print("Something else went wrong, probably internet")
                completionHandler(false)
            }
        }
    }
    
}
