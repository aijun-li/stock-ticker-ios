//
//  SearchInfo.swift
//  StockTicker
//
//  Created by 李爱军 on 2020/11/28.
//

import Foundation

struct SearchInfo {
    let ticker: String
    let company: String
    
    init(_ ticker: String, _ company: String) {
        self.ticker = ticker
        self.company = company
    }
}
