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

extension InstagramLoginViewController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let requestURLString = (request.url?.absoluteString)! as String
        print("**** URL String : \(requestURLString)")
        
        
        if requestURLString.hasPrefix(InstagramClient.Constants.REDIRECT_URI) {
            //let range: Range<String.Index> = requestURLString.range(of: "#access_token=")!
            let accessToken = requestURLString.range(of: "#access_token=")
            print("**** ACCESS TOKEN = \(String(describing: accessToken))")
            //handleAuth(authToken: requestURLString.substring(from: range.upperBound))
            return false;
        }
        return true
        //return checkRequestForCallbackURL(request: request)
    }
    
}


class InstagramLoginViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        
        showInstagramLogin()
    }
    
    func showInstagramLogin() {
        
        let url = InstagramClient.sharedInstance().getLoginURL()
        let request = URLRequest(url: url)
        webView.loadRequest(request)
    }
    @IBAction func performLogout(_ sender: UIButton) {
        let logoutRequest = URLRequest(url: URL(string: "https://instagram.com/accounts/logout")! as URL)//logout from webview browser
        webView.loadRequest(logoutRequest)
        //self.dismiss(animated: true, completion: nil)
    }
}
