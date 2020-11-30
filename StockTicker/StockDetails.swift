//
//  StockDetails.swift
//  StockTicker
//
//  Created by 李爱军 on 2020/11/27.
//

import SwiftUI
import SwiftyJSON
import KingfisherSwiftUI

struct StockDetails: View {
    let ticker: String
    @AppStorage("portfolio") var portfolioStored: String = ""
    @AppStorage("favorites") var favoritesStored: String = ""
    @AppStorage("cash") var cash: Double = 0.0
    @State var portfolio: [StockInfo] = []
    @State var favorites: [StockInfo] = []
    @State var details: StockInfo!
    @State var news: [NewsItem] = []
    @State var fetched = false
    @State var isFavorite = false
    @State var isLimited = true
    let group = DispatchGroup()
    let formatter = DateFormatter()
    
    init(ticker: String) {
        self.ticker = ticker
        
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
    }
    
    var body: some View {
        if (!fetched) {
            ProgressView {
                Text("Fetching Data...")
            }
            .onAppear {
                details = StockInfo(ticker)
                fetchDetails()
                buildArrays()
                getSharesAndFavorite()
            }
        } else {
            ScrollView(.vertical) {
                VStack {
                    // header section
                    VStack {
                        HStack {
                            Text(details.company)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        HStack {
                            Text("$\(details.latest.last.toFixed(to: 2)) ")
                                .font(.title)
                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                            Text("($\(details.latest.change.toFixed(to: 2)))")
                                .foregroundColor(details.latest.change > 0 ? .green : details.latest.change < 0 ? .red : .gray)
                                .font(.body)
                                .padding(.top, 3)
                            Spacer()
                        }
                    }
                    
                    // chart section
                    
                    
                    // portfolio section
                    VStack {
                        HStack {
                            Text("Portfolio")
                                .font(.title2)
                            Spacer()
                        }
                        HStack {
                            VStack {
                                if (details.shares > 0) {
                                    Text("Shares Owned: \(details.shares.toFixed(to: 4))")
                                    Text("Market Value: $\((details.shares * details.latest.last).toFixed(to: 2))")
                                        .padding(.top, 2)
                                } else {
                                    Text("You have 0 shares of \(ticker).\nStart trading!")
                                }
                            }
                            .font(.footnote)
                            Spacer()
                            Button("Trade") {
                                
                            }
                            .frame(width: 150, height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(100)
                        }
                        .padding(.top, 10)
                    }
                    .padding(.top)
                    
                    // stats section
                    VStack {
                        HStack {
                            Text("Stats")
                                .font(.title2)
                            Spacer()
                        }
                        ScrollView(.horizontal) {
                            LazyHGrid(rows: Array(repeating: GridItem(spacing: 20, alignment: .leading), count: 3), spacing: 30) {
                                Text("Current Price: \(details.latest.last.toFixed(to: 2))")
                                Text("Open Price: \(details.latest.open.toFixed(to: 2))")
                                Text("High: \(details.latest.high.toFixed(to: 2))")
                                Text("Low: \(details.latest.low.toFixed(to: 2))")
                                Text("Mid: \(details.latest.mid.toFixed(to: 2))")
                                Text("Volume: \(details.latest.volume)")
                                Text("Bid Price: \(details.latest.bid.toFixed(to: 2))")
                            }
                        }
                        .font(.footnote)
                        .padding(.top, 10)
                    }
                    .padding(.top)
                    
                    // about section
                    VStack {
                        HStack {
                            Text("About")
                                .font(.title2)
                            Spacer()
                        }
                        HStack {
                            Text(details.description)
                                .font(.footnote)
                                .padding(.top, 10)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(isLimited ? 2 : nil)
                            Spacer()
                        }
                        HStack {
                            Spacer()
                            Button(isLimited ? "Show more..." : "Show less") {
                                withAnimation {
                                    isLimited = !isLimited
                                }
                            }
                            .foregroundColor(.gray)
                            .font(.footnote)
                        }
                    }
                    .padding(.top)
                    
                    // news section
                    Group {
                        HStack {
                            Text("News")
                                .font(.title2)
                            Spacer()
                        }
                        if (news.count > 0) {
                            Link(destination: URL(string: news[0].url)!) {
                                VStack {
                                    KFImage(URL(string: news[0].img)!)
                                        .resizable()
                                        .scaledToFill()
                                        .cornerRadius(10)
                                        .clipped()
                                    VStack {
                                        HStack {
                                            Text("\(news[0].source) ")
                                                .fontWeight(.bold)
                                            Text(news[0].diff)
                                            Spacer()
                                        }
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .padding(.top, 10)
                                        .padding(.bottom, 0.5)
                                        HStack {
                                            Text(news[0].title)
                                                .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                                .fixedSize(horizontal: false, vertical: true)
                                            Spacer()
                                        }
                                    }
                                    .padding(.horizontal, 5)
                                    .padding(.bottom, 2)
                                }
                            }
                            .foregroundColor(.black)
                            .background(Color.white)
                            .contentShape(RoundedRectangle(cornerRadius: 10))
                            .buttonStyle(MyButtonStyle())
                            .contextMenu {
                                Link(destination: URL(string: news[0].url)!) {
                                    Label("Open in Safari", systemImage: "safari")
                                }
                                Link(destination: URL(string: "https://twitter.com/intent/tweet?\(getQueryText(news[0].url))")!) {
                                    Label("Share on Twitter", systemImage: "square.and.arrow.up")
                                }
                            }
                            
                            Divider()
                            
                            // news list
                            ForEach (1..<news.count, id: \.self) { index in
                                NewsListItem(news: news[index])
                            }
                        }
                    }
                    .padding(.top)
                    
                    Spacer()
                }
                .navigationTitle(ticker)
                .padding(.horizontal)
            }
        }
    }
    
    // get initial shares and favorite info
    func getSharesAndFavorite() {
        if let index = portfolio.firstIndex(where: { $0.ticker == self.ticker }) {
            details.shares = portfolio[index].shares
        }
        if favorites.contains(where: { $0.ticker == self.ticker }) {
            isFavorite = true
        }
    }
    
    func fetchDetails() {
        group.enter()
        fetchMeta()
        
        group.enter()
        fetchLatestPrice()
        
        group.enter()
        fetchNews()
        
        group.notify(queue: .main) {
            fetched = true
        }
    }
    
    func fetchMeta() {
        HTTP.getMeta(ticker: ticker) { data in
            if let company = data["name"].string {
                details.company = company
            }
            if let desc = data["description"].string {
                details.description = desc
            }
            
            group.leave()
        }
        
    }
    
    func fetchLatestPrice() {
        HTTP.getLatestPrice(tickers: ticker) { data in
            let keys: [String] = ["last", "prevClose", "open", "high", "low", "mid", "bidPrice", "volume"]
            
            for key in keys {
                if data[0][key] != JSON.null {
                    let val = data[0][key].double!
                    switch key {
                    case "last": details.latest.last = val
                    case "prevClose": details.latest.prevClose = val
                    case "open": details.latest.open = val
                    case "high": details.latest.high = val
                    case "low": details.latest.low = val
                    case "mid": details.latest.mid = val
                    case "bidPrice": details.latest.bid = val
                    case "volume": details.latest.volume = data[0][key].int!
                    default: break
                    }
                }
            }
            details.latest.change = details.latest.last - details.latest.prevClose
            
            group.leave()
        }
    }
    
    func fetchNews() {
        HTTP.getNews(ticker: ticker) { data in
            let keys: [String] = ["url", "title", "desc", "source", "img", "date"]
            for (_, item): (String, JSON) in data {
                var tmp = NewsItem()
                for key in keys {
                    if let val = item[key].string {
                        switch key {
                        case "url": tmp.url = val
                        case "title": tmp.title = val
                        case "desc": tmp.desc = val
                        case "source": tmp.source = val
                        case "img": tmp.img = val
                        case "date": tmp.date = val
                        default: break
                        }
                    }
                }
                tmp.diff = calcDateDiff(date: tmp.date)
                news.append(tmp)
            }
            
            group.leave()
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
    
    func calcDateDiff(date: String) -> String {
        let origin = formatter.date(from: date)!
        let diff = Int(Date().timeIntervalSince(origin))
        
        if diff >= 24*60*60 {
            let days = diff / (24*60*60)
            return "\(days) \(days == 1 ? "day" : "days") ago"
        } else if diff >= 60*60 {
            let hours = diff / (60*60)
            return "\(hours) \(hours == 1 ? "hour" : "hours") ago"
        } else {
            let minutes = diff / 60
            return "\(minutes) \(minutes > 1 ? "minutes" : "minute") ago"
        }
    }
    
    func getQueryText(_ url: String) -> String {
        let query = "text=Check out this link:&url=\(url)&hashtags=CSCI571StockApp"
        return query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
}

struct NewsListItem: View {
    let news: NewsItem
    var body: some View {
        Link(destination: URL(string: news.url)!) {
            HStack {
                VStack {
                    HStack {
                        Text("\(news.source) ")
                            .fontWeight(.bold)
                        Text(news.diff)
                        Spacer()
                    }
                    .font(.footnote)
                    .foregroundColor(.gray)
                    
                    HStack {
                        Text(news.title)
                            .fontWeight(.bold)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(3)
                        Spacer()
                    }
                }
                .padding(.leading, 5)
                
                KFImage(URL(string: news.img)!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 95, height: 95)
                    .cornerRadius(10)
                    .clipped()
            }
        }
        .foregroundColor(.black)
        .background(Color.white)
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .buttonStyle(MyButtonStyle())
        .contextMenu {
            Link(destination: URL(string: news.url)!) {
                Label("Open in Safari", systemImage: "safari")
            }
            Link(destination: URL(string: "https://twitter.com/intent/tweet?\(getQueryText(news.url))")!) {
                Label("Share on Twitter", systemImage: "square.and.arrow.up")
            }
        }
    }
    
    func getQueryText(_ url: String) -> String {
        let query = "text=Check out this link:&url=\(url)&hashtags=CSCI571StockApp"
        return query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }
}

struct MyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(1)
    }
}

struct StockDetails_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            StockDetails(ticker: "AMZN")
        }
    }
}
