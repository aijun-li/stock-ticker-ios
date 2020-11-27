//
//  TestData.swift
//  StockTicker
//
//  Created by 李爱军 on 2020/11/26.
//

import Foundation

func generateOne() -> StockInfo {
    var tmp = StockInfo("AAPL")
    tmp.latest.change = 5.126
    tmp.shares = 10
    tmp.company = "APPLE INC"
    return tmp
}


var testPortfolio = generateOne()
