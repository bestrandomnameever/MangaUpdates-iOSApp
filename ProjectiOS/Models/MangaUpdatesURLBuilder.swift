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
        self.url.append("search=")
        self.url.append(title.replacingOccurrences(of: " ", with: "+"))
        self.url.append("&")
        return self
    }
    
    func includeGenres(_ genres: [String]) -> MangaUpdatesURLBuilder{
        self.url.append("genre=")
        self.url.append(genres.joined(separator: "_").replacingOccurrences(of: " ", with: "%2B"))
        self.url.append("&")
        return self
    }
    
    func excludeGenres(_ genres: [String]) -> MangaUpdatesURLBuilder{
        self.url.append("exclude_genre=")
        self.url.append(genres.joined(separator: "_").replacingOccurrences(of: " ", with: "%2B"))
        self.url.append("&")
        return self
    }
    
    func withCategories(_ categories: [String]) -> MangaUpdatesURLBuilder{
        if categories.count > 0 {
            self.url.append("category=")
            var variableCategorys = categories
            for (index, category) in variableCategorys.enumerated() {
                variableCategorys[index] = category.replacingOccurrences(of: " ", with: "%2B").replacingOccurrences(of: "/", with: "%252F").replacingOccurrences(of: "'", with: "%27")
            }
            self.url.append(variableCategorys.joined(separator: "_"))
            self.url.append("&")
        }
        return self
    }
    
    func resultsPerPage(amount: Int) -> MangaUpdatesURLBuilder{
        self.url.append("perpage=")
        self.url.append(String.init(amount))
        self.url.append("&")
        return self
    }
    
    func licensed(_ license: LicenseOptions) -> MangaUpdatesURLBuilder{
        if license != .all {
            self.url.append(license.rawValue)
            self.url.append("&")
        }
        return self
    }
    
    func extendedOptions(_ option: ExtendedOptions) -> MangaUpdatesURLBuilder{
        if option != .all {
            self.url.append(option.rawValue)
            self.url.append("&")
        }
        return self
    }
    
    func typeOptions(_ type: TypeOptions) -> MangaUpdatesURLBuilder{
        if type != .all {
            self.url.append(type.rawValue)
            self.url.append("&")
        }
        return self
    }
    
    func orderBy(_ order: OrderBy) -> MangaUpdatesURLBuilder{
        self.url.append(order.rawValue)
        self.url.append("&")
        return self
    }
    
    //TODO zou leuk zijn indien hij de oude page verwijderd en nieuwe invult maar momenteel gewoon nieuw atribuut aan URL toevoegen
    func getPage(page : Int) -> MangaUpdatesURLBuilder{
        self.url.append("page="+String.init(page))
        self.url.append("&")
        return self
    }
    
    func getUrl() -> URL{
        return URL.init(string: self.url)!
    }
    
}

enum LicenseOptions: String{
    case all = ""
    case onlyLicensed = "licensed=yes"
    case onlyUnlicensed = "licensed=no"
}

enum ExtendedOptions: String{
    case all = ""
    case completeScanlated = "filter=scanlated"
    case completeScanlatedIncludingOneShots = "filter=completed"
    case oneShot = "filter=oneshots"
    case excludeOneShot = "filter=no_oneshots"
    case atLeastOneRelease = "filter=some_releases"
    case noRelease = "filter=no_releases"
}
enum TypeOptions: String{
    case all = ""
    case artbook = "type=artbook"
    case doujinshi = "type=doujinshi"
    case dramaCd = "type=drama_cd"
    case manga = "type=manga"
    case manhwa = "type=manhwa"
    case manhua = "type=manhua"
    case thai = "type=thai"
    case indonesian = "type=indonesian"
    case novel = "type=novel"
    case oel = "type=oel"
}

enum OrderBy: String{
    case rating = "orderby=rating"
    case title = "orderby=title"
}


