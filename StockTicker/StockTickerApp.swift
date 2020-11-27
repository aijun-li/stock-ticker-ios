//
//  StockTickerApp.swift
//  StockTicker
//
//  Created by 李爱军 on 2020/11/21.
//

import SwiftUI

@main
struct StockTickerApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}

extension Double {
    func toFixed(to digits: Int) -> String {
        return String(format: "%.\(digits)f", self)
    }
}
