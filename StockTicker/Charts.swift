//
//  Charts.swift
//  StockTicker
//
//  Adapted from "https://developer.apple.com/forums/thread/126986"
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @Binding var title: String
    var url: URL
    var loadStatusChanged: ((Bool, Error?) -> Void)? = nil
    
    func makeCoordinator() -> WebView.Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let view = WKWebView()
        view.navigationDelegate = context.coordinator
        view.load(URLRequest(url: url))
        return view
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // you can access environment via context.environment here
        // Note that this method will be called A LOT
    }
    
    func onLoadStatusChanged(perform: ((Bool, Error?) -> Void)?) -> some View {
        var copy = self
        copy.loadStatusChanged = perform
        return copy
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: WebView
        
        init(_ parent: WebView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
            parent.loadStatusChanged?(true, nil)
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.title = webView.title ?? ""
            parent.loadStatusChanged?(false, nil)
        }
        
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            parent.loadStatusChanged?(false, error)
        }
    }
}

struct Charts: View {
    let ticker: String
    @State var title: String = ""
    @State var error: Error? = nil
    
    var body: some View {
        WebView(title: $title, url: URL(string: "https://mystockticker-pro-225417.wm.r.appspot.com/ios/charts/\(ticker)")!)
            .onLoadStatusChanged { loading, error in
                if loading {
                    print("Loading started")
                    self.title = "Loading…"
                }
                else {
                    print("Done loading.")
                    if let error = error {
                        self.error = error
                        if self.title.isEmpty {
                            self.title = "Error"
                        }
                    }
                    else if self.title.isEmpty {
                        self.title = "Some Place"
                    }
                }
            }
    }
}

struct WebView_Previews: PreviewProvider {
    static var previews: some View {
        Charts(ticker: "AMZN")
            .padding()
    }
}
