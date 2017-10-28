//
//  InstagramLoginViewController.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 10/27/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//

import Foundation
import UIKit
import WebKit

extension InstagramLoginViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("***** Test TEST")
        
        let urlString = webView.url?.absoluteString
        let accessToken = urlString!.range(of: "#access_token=")
        print("***** URL String\(String(describing: urlString))")
        print("***** Access token : \(accessToken)")
        
        //print("webView:\(webView) decidePolicyForNavigationAction:\(navigationAction) decisionHandler:\(decisionHandler)")
        /*
        switch navigation.navigationType {
        case .linkActivated: break
            /*
             if navigationAction.targetFrame == nil {
             self.webView?.load(navigationAction.request)
             }
             if let url = navigationAction.request.URL,, !url.absoluteString.hasPrefix("http://www.myWebSite.com/example") {
             UIApplication.sharedApplication().openURL(url)
             print(url.absoluteString)
             decisionHandler(.Cancel)
             return
             }
             */
        default:
            break
        }
        
        if let url = navigation.request.url {
            print(url.absoluteString)
        }
        decisionHandler(.allow)
 */
    }
}

/*
extension InstagramLoginViewController: WKUIDelegate {
    /*
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        print("***** Test")
        return true
        //return checkRequestForCallbackURL(request: request)
    }
    */
}
*/

class InstagramLoginViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        
        showInstagramLogin()
    }
    
    func showInstagramLogin() {
        
        let url = InstagramClient.sharedInstance().getLoginURL()
        let request = URLRequest(url: url)
        webView.load(request)
    }
    @IBAction func performLogout(_ sender: UIButton) {
        let logoutRequest = URLRequest(url: URL(string: "https://instagram.com/accounts/logout")! as URL)//logout from webview browser
        webView.load(logoutRequest)
        //self.dismiss(animated: true, completion: nil)
    }
}
