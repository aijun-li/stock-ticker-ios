//
//  TradeSheet.swift
//  StockTicker
//
//  Created by 李爱军 on 2020/11/30.
//

import SwiftUI
import Combine

struct TradeSheet: View {
    @Binding var details: StockInfo!
    @Binding var showSheet: Bool
    @AppStorage("cash") var cash: Double = 0.0
    @State var showToast = false
    @State var toastContent: String = ""
    @State var input: String = ""
    @State var finished = false
    @State var dealType: Int = -1
    var amount: Double? {
        Double(input)
    }
    var total: Double {
        if let amount = self.amount {
            return amount * details.latest.last
        } else {
            return 0
        }
    }
    
    var body: some View {
        if !finished {
            VStack {
                HStack {
                    Button(action: { withAnimation { showSheet = false } }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.black)
                    }
                    Spacer()
                }
                
                Text("Trade \(details.company) shares")
                    .fontWeight(.bold)
                    .padding()
                
                VStack {
                    Spacer()
                    
                    HStack(alignment: .firstTextBaseline) {
                        TextField("0", text: $input)
                            .font(.system(size: 95, weight: .light))
                            .keyboardType(.decimalPad)
                        
                        
                        Text("Share\(amount != nil && amount! > 1 ? "s" : "")")
                            .font(.system(size: 35))
                    }
                    
                    HStack {
                        Spacer()
                        Text("x $\(details.latest.last.toFixed(to: 2))/share = \(total.toFixed(to: 2))")
                    }
                    
                    Spacer()
                }
                
                Text("$\(cash.toFixed(to: 2)) available to buy \(details.ticker)")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding()
                
                HStack {
                    Button(action: { buy() }) {
                        Text("Buy")
                            .frame(width: 180, height: 50)
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(100)
                    }
                    
                    Spacer()
                    
                    Button(action: { sell() }) {
                        Text("Sell")
                            .frame(width: 180, height: 50)
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(100)
                    }
                }
            }
            .padding()
            .toast(isPresented: $showToast) {
                Text(toastContent)
                    .foregroundColor(.white)
            }
        } else {
            VStack {
                Spacer()
                
                VStack {
                    Text("Congratulations!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    Text("You have successfully \(dealType == 0 ? "bought" : "sold") \(input) share\(amount! > 1 ? "s" : "") of \(details.ticker)")
                        .font(.callout)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 35)
                
                Spacer()
                
                Button(action: { withAnimation{ showSheet = false } }) {
                    Text("Done")
                        .fontWeight(.bold)
                        .frame(minWidth:0, maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.green)
                        .background(Color.white)
                        .cornerRadius(100)
                }
            }
            .padding()
            .padding(.bottom, 35)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.green)
            .foregroundColor(.white)
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    func buy() {
        guard validate(type: 0) else {
            return
        }
        details.shares += amount!
        cash -= total
        dealType = 0
        withAnimation {
            finished = true
        }
    }
    
    func sell() {
        guard validate(type: 1) else {
            return
        }
        details.shares -= amount!
        cash += total
        dealType = 1
        withAnimation {
            finished = true
        }
    }
    
    func validate(type: Int) -> Bool {
        guard let amount = self.amount else {
            toastContent = "Please enter a valid amount"
            showToast = true
            return false
        }
        
        if amount <= 0 {
            toastContent = "Cannot \(type == 0 ? "buy" : "sell") less than 0 share"
            showToast = true
            return false
        } else if type == 0 && total > cash {
            toastContent = "Not enough money to buy"
            showToast = true
            return false
        } else if type == 1 && amount > details.shares {
            toastContent = "Not enough shares to sell"
            showToast = true
            return false
        } else {
            return true
        }
    }
}

//struct TradeSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        TradeSheet(name: "Microsoft Corporation")
//    }
//}
