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
    
    private var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Background solid black set karein (pink aur white flash hatane ke liye)
        view.backgroundColor = .black
        
        // 2. WKWebView ko background & inline media playback ke liye configure karein
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsAirPlayForMediaPlayback = true
        config.userContentController.add(self, name: "myHandler")
        
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" +
            "head.appendChild(meta);"
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        config.userContentController.addUserScript(script)
        
        webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black
        webView.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 16.4, *) {
            webView.isInspectable = true
        }
        
        self.view.addSubview(self.webView)
        NSLayoutConstraint.activate([
            self.webView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
            self.webView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            self.webView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
            self.webView.topAnchor.constraint(equalTo: self.view.topAnchor),
        ])
        
        // 3. Status bar background ko pink se black kar diya gaya hai
        let statusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
        let statusbarView = UIView()
        statusbarView.backgroundColor = .black
        statusbarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusbarView)
        
        NSLayoutConstraint.activate([
            statusbarView.heightAnchor.constraint(equalToConstant: statusBarHeight),
            statusbarView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0),
            statusbarView.topAnchor.constraint(equalTo: view.topAnchor),
            statusbarView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // 4. Aapka Music URL load karein
        if let url = URL(string: "https://aquiluxoffical.github.io/Music/") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        self.view.bringSubviewToFront(statusbarView)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
