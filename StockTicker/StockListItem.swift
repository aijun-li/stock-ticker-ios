//
//  StockListItem.swift
//  StockTicker
//
//  Created by 李爱军 on 2020/11/25.
//

import SwiftUI
import Combine

struct StockListItem: View {
    var item: StockInfo
    
    var body: some View {
        VStack {
            HStack {
                Text(item.ticker)
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text(item.latest.last.toFixed(to: 2))
                    .fontWeight(.bold)
                
            }
            HStack {
                if (item.shares > 0) {
                    Text("\(item.shares.toFixed(to: 2)) share\(item.shares > 1 ? "s" : "")")
                        .foregroundColor(.gray)
                } else {
                    Text(item.company)
                        .foregroundColor(.gray)
                }
                Spacer()
                HStack {
                    if item.latest.change != 0 {
                        Image(systemName: item.latest.change < 0 ?  "arrow.down.right" : "arrow.up.right")
                            .padding(.horizontal, 8)
                    }
                    Text("\(item.latest.change.toFixed(to: 2))")
                }
                .foregroundColor(item.latest.change > 0 ? .green : item.latest.change < 0 ? .red : .gray)
            }
        }
    }
}

//struct StockListItem_Previews: PreviewProvider {
//    static var previews: some View {
//        StockListItem(item: testPortfolio)
//            .previewLayout(.sizeThatFits)
//    }
//}
