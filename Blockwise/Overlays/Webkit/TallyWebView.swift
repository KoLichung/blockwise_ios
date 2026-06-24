//
//  TallyWebView.swift
//  Blockwise
//
//  Created by Ivan Sanna on 13/03/26.
//

import SwiftUI
import WebKit

struct TallyWebView: UIViewRepresentable {
    let url: URL
    var onComplete: () -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.load(URLRequest(url: url))
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onComplete: onComplete)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        var onComplete: () -> Void
        init(onComplete: @escaping () -> Void) {
            self.onComplete = onComplete
        }
        
        func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction) async -> WKNavigationActionPolicy {
            if action.request.url?.scheme == "blockwise" {
                onComplete()
                return .cancel
            }
            return .allow
        }
    }
}
