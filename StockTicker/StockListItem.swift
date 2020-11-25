//
//  StockListItem.swift
//  StockTicker
//
//  Created by 李爱军 on 2020/11/25.
//

import SwiftUI

struct StockListItem: View {
    var body: some View {
        VStack {
            HStack {
                Text("AAPL")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("111.20")
                    .fontWeight(.bold)
            }
            HStack {
                Text("10.00 shares")
                    .foregroundColor(.secondary)
                Spacer()
                HStack {
                    Image(systemName: "arrow.down.right")
                        .padding(.horizontal, 8)
                    Text("-5.40")
                }
                .foregroundColor(.red)
            }
        }
    }
}

struct StockListItem_Previews: PreviewProvider {
    static var previews: some View {
        StockListItem()
            .previewLayout(.sizeThatFits)
    }
}
