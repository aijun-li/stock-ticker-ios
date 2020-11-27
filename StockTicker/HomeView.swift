//
//  ContentView.swift
//  StockTicker
//
//  Created by 李爱军 on 2020/11/21.
//

import SwiftUI
import SwiftyJSON
import Combine

struct HomeView: View {
    @State var date: Date = Date()
    @ObservedObject var searchBar: SearchBar = SearchBar()
    @AppStorage("portfolio") var portfolioStored: String = ""
    @AppStorage("favorites") var favoritesStored: String = ""
    @AppStorage("cash") var cash: Double = 0.0
    @State var portfolio: [StockInfo] = []
    @State var favorites: [StockInfo] = []
    @State var finishedCount = 0
    var net: Double {
        var sum = cash
        portfolio.forEach { item in
            sum += item.shares * item.latest.last
        }
        return sum
    }
    let timer = Timer.publish(every: 15, on: .main, in: .common).autoconnect()
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
                            HStack {
                                Text("Net Worth")
                                    .font(.title)
                                Spacer()
                            }
                            HStack {
                                Text("\(net.toFixed(to: 2))")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Spacer()
                            }
                        }
                        
                        ForEach(portfolio, id: \.ticker) { item in
                            NavigationLink(destination: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Destination@*/Text("Destination")/*@END_MENU_TOKEN@*/) {
                                StockListItem(item: item)
                            }
                        }
                        .onMove(perform: moveItem(type: 0))
                        .onDelete(perform: deleteItem(type: 0))
                    }
                    
                    // Favorites Section
                    Section(header: Text("Favorites")) {
                        ForEach(favorites, id: \.ticker) { item in
                            NavigationLink(destination: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Destination@*/Text("Destination")/*@END_MENU_TOKEN@*/) {
                                StockListItem(item: item)
                            }
                        }
                        .onMove(perform: moveItem(type: 1))
                        .onDelete(perform: deleteItem(type: 1))
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
                .onReceive(timer, perform: { _ in
                    fetchData(type: 0, toInit: false)
                    fetchData(type: 1, toInit: false)
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
            } else {
                print("\(type == 0 ? "Portfolio" : "Favorites") data updated.")
            }
        }
    }
    
    // move item in the list
    func moveItem(type: Int) -> (IndexSet, Int)->Void {
        if (type == 0) {
            return { from, to in
                withAnimation {
                    portfolio.move(fromOffsets: from, toOffset: to)
                    portfolioStored = portfolio.map { "\($0.ticker)|\($0.shares)" }.joined(separator: ",")
                }
            }
        } else {
            return { from, to in
                withAnimation {
                    favorites.move(fromOffsets: from, toOffset: to)
                    favoritesStored = favorites.map { "\($0.ticker)|\($0.company)" }.joined(separator: ",")
                }
            }
        }
    }
    
    // delete item in the list
    func deleteItem(type: Int) -> (IndexSet)->Void {
        if (type == 0) {
            return { offests in
                withAnimation {
                    portfolio.remove(atOffsets: offests)
                    portfolioStored = portfolio.map { "\($0.ticker)|\($0.shares)" }.joined(separator: ",")
                }
            }
        } else {
            return { offsets in
                withAnimation {
                    favorites.remove(atOffsets: offsets)
                    favoritesStored = favorites.map { "\($0.ticker)|\($0.company)" }.joined(separator: ",")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
