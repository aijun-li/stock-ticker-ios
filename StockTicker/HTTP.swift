//
//  HTTP.swift
//  StockTicker
//
//  Created by 李爱军 on 2020/11/26.
//

import Foundation
import Alamofire
import SwiftyJSON

struct HTTP {
    static func getLatestPrice(tickers: String, callback: @escaping (JSON) -> Void) {
        AF.request("https://mystockticker-pro-225417.wm.r.appspot.com/api/details/latest?tickers=\(tickers)").validate().responseJSON { response in
            if let data = response.data {
                callback(JSON(data))
            } else {
                callback(JSON(parseJSON: "[]"))
                print("HTTP error: Fetching latest price failed!\n")
            }
        }
    }
    
    static func getSuggestions(keyword: String, callback: @escaping (JSON) -> Void) {
        AF.request("https://mystockticker-pro-225417.wm.r.appspot.com/api/suggestions/\(keyword)").validate().responseJSON { response in
            if let data = response.data {
                callback(JSON(data))
            } else {
                callback(JSON(parseJSON: "[]"))
            }
        }
    }
    
    static func getMeta(ticker: String, callback: @escaping (JSON) -> Void) {
        AF.request("https://mystockticker-pro-225417.wm.r.appspot.com/api/details/meta/\(ticker)").validate().responseJSON { response in
            if let data = response.data {
                callback(JSON(data))
            } else {
                callback(JSON(parseJSON: "{}"))
                print("HTTP error: Fetching meta info failed!\n")
            }
        }
    }
    
    static func getNews(ticker: String, callback: @escaping (JSON) -> Void) {
        AF.request("https://mystockticker-pro-225417.wm.r.appspot.com/api/news/\(ticker)").validate().responseJSON { response in
            if let data = response.data {
                callback(JSON(data))
            } else {
                callback(JSON(parseJSON: "[]"))
                print("HTTP error: Fetching news failed!\n")
            }
        }
    }
}
