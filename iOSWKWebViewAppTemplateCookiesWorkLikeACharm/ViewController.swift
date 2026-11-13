//
//  ViewController.swift
//  iOSWKWebViewAppTemplateCookiesWorkLikeACharm
//
//

import UIKit
import WebKit

extension ViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        if message.name == "myHandler" {
            let data = message.body
            print("LOG: \(data)")
        }
    }
}

class ViewController: UIViewController {
    
    private let webView = WKWebView(frame: .zero)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let app = UIApplication.shared
        let statusBarHeight: CGFloat = app.statusBarFrame.size.height
        
        let statusbarView = UIView()
        statusbarView.backgroundColor = UIColor(red: 0.93, green: 0, blue: 1, alpha: 1)
        view.addSubview(statusbarView)
        
        statusbarView.translatesAutoresizingMaskIntoConstraints = false
        statusbarView.heightAnchor.constraint(equalToConstant: statusBarHeight).isActive = true
        statusbarView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        statusbarView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        statusbarView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(self.webView)
        NSLayoutConstraint.activate([
            self.webView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.webView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.webView.topAnchor.constraint(equalTo: self.view.topAnchor),
        ])
        self.view.setNeedsLayout()
        
        // --- URL UPDATE 1/2 (Yahan aapka music link daal diya gaya hai) ---
        if let url = URL(string: "https://aquiluxoffical.github.io/Music/") {
            let request = URLRequest(url: url)
            webView.load(request)
            
            webView.isInspectable = true
            webView.configuration.userContentController.add(self, name: "myHandler")
            let helloWorldScript = "window.webkit.messageHandlers.myHandler/postMessage('Hello World!');"
            webView.evaluateJavaScript(helloWorldScript, completionHandler: nil)
            
            let source: String = "var meta = document.createElement('meta');" +
                "meta.name = 'viewport';" +
                "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
                "var head = document.getElementsByTagName('head')[0];" +
                "head.appendChild(meta);"
            
            let script: WKUserScript = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
            webView.configuration.userContentController.addUserScript(script)
        }
        
        self.view.bringSubviewToFront(statusbarView);
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
}

// --- URL UPDATE 2/2 (File ke end mein bhi URL update kar diya gaya hai) ---
let url = URL(string: "https://aquiluxoffical.github.io/Music/")!
