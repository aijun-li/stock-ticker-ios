//
//  ContentView.swift
//  StockTicker
//
//  Created by 李爱军 on 2020/11/21.
//

import SwiftUI
import SwiftyJSON

struct HomeView: View {
    @State var date: Date = Date()
    @ObservedObject var searchBar: SearchBar = SearchBar()
    @AppStorage("portfolio") var portfolioStored: String = ""
    @AppStorage("favorites") var favoritesStored: String = ""
    @State var portfolio: [StockInfo] = []
    @State var favorites: [StockInfo] = []
    @State var finishedCount = 0;
    
    
    let formatter: DateFormatter = DateFormatter()
    
    init() {
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
    }
    
    var body: some View {
        NavigationView {
            if (finishedCount != 2) {
                ProgressView() {
                    Text("Fetching Data...")
                }
                .navigationTitle("Stocks")
                .onAppear {
                    buildArrays()
                    fetchData(type: 0, toInit: true)
                    fetchData(type: 1, toInit: true)
                }
            } else {
                List {
                    // Date Section
                    Text(formatter.string(from: date))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    
                    // Portfolio Section
                    Section(header: Text("Portfolio")) {
                        VStack {
                            Text("Net Worth")
                                .font(.title)
                            Text("19961.60")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        
                        ForEach(portfolio, id: \.ticker) { item in
                            NavigationLink(destination: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Destination@*/Text("Destination")/*@END_MENU_TOKEN@*/) {
                                StockListItem(item: item)
                            }
                        }
                        .onMove(perform: moveItem)
                        .onDelete(perform: deleteItem)
                    }
                    
                    // Favorites Section
                    Section(header: Text("Favorites")) {
                        ForEach(favorites, id: \.ticker) { item in
                            NavigationLink(destination: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Destination@*/Text("Destination")/*@END_MENU_TOKEN@*/) {
                                StockListItem(item: item)
                            }
                        }
                        .onMove(perform: moveItem)
                        .onDelete(perform: deleteItem)
                    }
                    
                    // Footer
                    HStack {
                        Spacer()
                        Link(destination: URL(string: "https://www.tiingo.com")!) {
                            Text("Powered by Tiingo")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    
                }
                .navigationTitle("Stocks")
                .add(searchBar)
                .toolbar(content: {
                    EditButton()
                })
            }
        }
    }
    
    // initialize arrays based on stored information
    func buildArrays() {
        var portfolioTmp: [StockInfo] = []
        var favoritesTmp: [StockInfo] = []
        
        portfolioStored.split(separator: ",").forEach { s in
            let info = s.split(separator: "|")
            var item = StockInfo(String(info[0]))
            item.shares = Double(info[1])!
            portfolioTmp.append(item)
        }
        
        favoritesStored.split(separator: ",").forEach { s in
            let info = s.split(separator: "|")
            var item = StockInfo(String(info[0]))
            item.company = String(info[1])
            if let found = portfolioTmp.first(where: { $0.ticker.uppercased() == info[0].uppercased() }){
                item.shares = found.shares
            }
            favoritesTmp.append(item)
        }
        
        portfolio = portfolioTmp
        favorites = favoritesTmp
    }
    
    // fetch stock data
    func fetchData(type: Int, toInit: Bool) {
        let tickers = (type == 0 ? portfolioStored : favoritesStored) .split(separator: ",").map { $0.split(separator: "|")[0] }.joined(separator: ",")
        
        HTTP.getLatestPrice(tickers: tickers) { data in
            for (_, item): (String, JSON) in data {
                let index = (type == 0 ? portfolio : favorites).firstIndex { $0.ticker.uppercased() == item["ticker"].string!.uppercased() }
                if (type == 0) {
                    portfolio[index!].latest.last = item["last"].double!
                    portfolio[index!].latest.change = item["last"].double! - item["prevClose"].double!
                } else {
                    favorites[index!].latest.last = item["last"].double!
                    favorites[index!].latest.change = item["last"].double! - item["prevClose"].double!
                }
            }
            
            if (toInit) {
                finishedCount += 1;
            }
        }
    }
    
    
    func moveItem(from: IndexSet, to: Int) {
        withAnimation {
            
        }
    }
    
    func deleteItem(offsets: IndexSet) {
        withAnimation {
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
