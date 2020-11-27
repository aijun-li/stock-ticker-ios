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
        AF.request("https://mystockticker-pro-225417.wm.r.appspot.com/api/details/latest?tickers=\(tickers)").responseJSON { response in
            callback(JSON(response.data!))
        }
    }
}
