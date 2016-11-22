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

class MangaUpdatesAPI {
    let BaseUrl = "https://mangaupdates.com/"
    let ReleaseUrlExtension = "releases.html"
    let SeriesWithIdUrlExtension = "series.html?id="
    let SearchTitleExtension = "series.html?stype=utf8title&search="
    
    func getLatestReleases(count : Int) {
        Alamofire.request(BaseUrl + ReleaseUrlExtension).response {response in
            if let data = response.data, let utf8text = String.init(data: data, encoding: .utf8) {
                if let doc = Kanna.HTML(html: utf8text, encoding: .utf8) {
                    for link in doc.xpath("//a[@title='Series Info']") {
                        
                    }
                }
            }
        }
    }
    
}
