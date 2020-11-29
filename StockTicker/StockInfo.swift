//
//  StockInfo.swift
//  StockTicker
//
//  Created by 李爱军 on 2020/11/26.
//

struct StockInfo {
    let ticker: String
    var company: String = ""
    var description: String = ""
    var shares: Double = 0.0
    var latest: LatestPrice = LatestPrice()
    
    
    init(_ ticker:String) {
        self.ticker = ticker
    }
}

struct LatestPrice {
    var last = 0.0
    var prevClose = 0.0
    var open = 0.0
    var high = 0.0
    var low = 0.0
    var mid = 0.0
    var bid = 0.0
    var volume = 0
    var change = 0.0
}


