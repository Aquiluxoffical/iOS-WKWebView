//
//  ViewController.swift
//  iOSWKWebViewAppTemplateCookiesWorkLikeACharm
//
//

import UIKit
import WebKit
import AVFoundation

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
        
        // 1. Background solid black set karein
        view.backgroundColor = .black
        
        // 2. WKWebView ko background & inline media playback ke liye configure karein
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.allowsAirPlayForMediaPlayback = true
        config.allowsPictureInPictureMediaPlayback = true
        config.userContentController.add(self, name: "myHandler")
        
        // 3. YouTube IFrame ko background mein pause hone se rokne ka script (ALL FRAMES)
        let bgBypassJS = """
        Object.defineProperty(document, 'hidden', { get: function() { return false; }, configurable: true });
        Object.defineProperty(document, 'visibilityState', { get: function() { return 'visible'; }, configurable: true });
        document.addEventListener('visibilitychange', function(e) { e.stopImmediatePropagation(); }, true);
        window.addEventListener('pagehide', function(e) { e.stopImmediatePropagation(); }, true);
        """
        let bgScript = WKUserScript(source: bgBypassJS, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        config.userContentController.addUserScript(bgScript)
        
        // Viewport script
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
        
        // 4. Status bar background black
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
        
        // 5. Background aur Lock Screen observers
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        // 6. Aapka Music URL load karein
        if let url = URL(string: "https://aquiluxoffical.github.io/Music/") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        self.view.bringSubviewToFront(statusbarView)
    }
    
    // Minimize/Lock hone se theek pehle check karein ki gaana chal raha tha ya nahi
    @objc func appWillResignActive() {
        let checkJS = "window._wasPlayingBeforeBg = (typeof isPlaying !== 'undefined' && isPlaying);"
        webView.evaluateJavaScript(checkJS, completionHandler: nil)
    }
    
    // Background mein jaate hi audio session active rakh kar playback resume karein
    @objc func appDidEnterBackground() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        try? AVAudioSession.sharedInstance().setActive(true)
        
        let resumeJS = """
        if (window._wasPlayingBeforeBg && typeof player !== 'undefined' && player.playVideo) {
            player.playVideo();
        }
        """
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.webView.evaluateJavaScript(resumeJS, completionHandler: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { [weak self] in
            self?.webView.evaluateJavaScript(resumeJS, completionHandler: nil)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
