//
//  ContentView.swift
//  StockTicker
//
//  Created by 李爱军 on 2020/11/21.
//

import SwiftUI

struct HomeView: View {
    @State var date: Date = Date()
    @ObservedObject var searchBar: SearchBar = SearchBar()
    
    let formatter: DateFormatter = DateFormatter()
    
    init() {
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.timeZone = TimeZone(identifier: "America/Los_Angeles")
    }
    
    var body: some View {
        NavigationView {
            List {
                // Date Section
                Text(formatter.string(from: date))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                
                // Portfolio Section
                Section(header: Text("Portfolio")) {
                    VStack {
                        Text("Net Worth")
                            .font(.title)
                        Text("19961.60")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                    
                    ForEach(1..<5) { _ in
                        NavigationLink(destination: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Destination@*/Text("Destination")/*@END_MENU_TOKEN@*/) {
                            StockListItem()
                        }
                    }
                    .onMove(perform: moveItem)
                    .onDelete(perform: deleteItem)
                }
                
                // Favorites Section
                Section(header: Text("Favorites")) {
                    ForEach(1..<5) { _ in
                        NavigationLink(destination: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Destination@*/Text("Destination")/*@END_MENU_TOKEN@*/) {
                            StockListItem()
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
                            .foregroundColor(.secondary)
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
