//
//  CategorySearchResult.swift
//  ProjectiOS
//
//  Created by Anthony on 04/03/2017.
//  Copyright © 2017 Anthony. All rights reserved.
//

import Foundation

class CategorySearchResult {
    
    var categoryDictionary : Dictionary<String, String>?
    var hasNextPage : Bool
    var currentPage : String?
    
    init(categoryDictionary: Dictionary<String, String>?, hasNextPage: Bool) {
        self.categoryDictionary = categoryDictionary
        self.hasNextPage = hasNextPage
    }
    
    init(categoryDictionaryAsArray: [(category: String, url: String)]?, hasNextPage: Bool) {
        if let categorysAndUrls = categoryDictionaryAsArray {
            categoryDictionary = [:]
            for categoryAndUrl in categorysAndUrls {
                categoryDictionary![categoryAndUrl.category] = categoryAndUrl.url
            }
        }
        self.hasNextPage = hasNextPage
    }
}
