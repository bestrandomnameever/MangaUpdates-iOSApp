//
//  MangaUpdatesURLBuilder.swift
//  ProjectiOS
//
//  Created by Anthony on 18/01/2017.
//  Copyright © 2017 Anthony. All rights reserved.
//

import UIKit

class MangaUpdatesURLBuilder {
    
    var url : String
    
    init() {
        self.url = "https://mangaupdates.com/series.html?"
    }
    
    init(customUrl: URL) {
        self.url = customUrl.absoluteString
    }
    
    func releasesURL() -> URL{
        return URL.init(string: "https://mangaupdates.com/releases.html")!
    }
    
    func getMangaURLForId(id: String) -> URL{
        return URL.init(string: "https://mangaupdates.com/series.html?id="+id)!
    }
    
    func searchTitle(_ title: String) -> MangaUpdatesURLBuilder{
        if self.url.contains("&"){
            self.url.append("&")
        }
        self.url.append("search=")
        self.url.append(title.replacingOccurrences(of: " ", with: "+"))
        return self
    }
    
    func includeGenres(_ genres: [String]) -> MangaUpdatesURLBuilder{
        if self.url.contains("&"){
            self.url.append("&")
        }
        self.url.append("genre=")
        self.url.append(genres.joined(separator: "_").replacingOccurrences(of: " ", with: "%2B"))
        return self
    }
    
    func excludeGenres(_ genres: [String]) -> MangaUpdatesURLBuilder{
        if self.url.contains("&"){
            self.url.append("&")
        }
        self.url.append("exclude_genre=")
        self.url.append(genres.joined(separator: "_").replacingOccurrences(of: " ", with: "%2B"))
        return self
    }
    
    func resultsPerPage(amount: Int) -> MangaUpdatesURLBuilder{
        if self.url.contains("&"){
            self.url.append("&")
        }
        self.url.append("perpage=")
        self.url.append(String.init(amount))
        return self
    }
    
    func licensed(_ license: LicenseOptions) -> MangaUpdatesURLBuilder{
        if self.url.contains("&"){
            self.url.append("&")
        }
        self.url.append(license.rawValue)
        return self
    }
    
    func extendedOptions(_ option: ExtendedOptions) -> MangaUpdatesURLBuilder{
        if self.url.contains("&"){
            self.url.append("&")
        }
        self.url.append(option.rawValue)
        return self
    }
    
    func orderBy(_ order: OrderBy) -> MangaUpdatesURLBuilder{
        if self.url.contains("&"){
            self.url.append("&")
        }
        self.url.append(order.rawValue)
        return self
    }
    
    //zou leuk zijn indien hij de oude page verwijderd en nieuwe invuld maar momenteel gewoon nieuw atribuut aan URL toevoegen
    func getPage(page : Int) -> MangaUpdatesURLBuilder{
        if self.url.contains("&"){
            self.url.append("&")
        }
        self.url.append("page="+String.init(page))
        return self
    }
    
    func getUrl() -> URL{
        return URL.init(string: self.url)!
    }
    
}

enum LicenseOptions: String{
    case onlyLicensed = "licensed=yes"
    case onlyUnlicensed = "licensed=no"
}

enum ExtendedOptions: String{
    case all = ""
    case completeScanlated = "filter=scanlated"
    case complete = "filter=completed"
    case oneShot = "filter=oneshots"
    case excludeOneShot = "filter=no_oneshots"
    case atLeastOneRelease = "filter=some_releases"
    case noRelease = "filter=no_releases"
}

enum OrderBy: String{
    case rating = "orderby=rating"
    case title = "orderby=title"
}


