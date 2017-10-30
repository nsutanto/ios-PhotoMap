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

/*
protocol InstagramLogout {
    func performLogout()
}
*/
extension InstagramLoginViewController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let requestURLString = (request.url?.absoluteString)! as String
        print("**** URL String : \(requestURLString)")
        
        
        if requestURLString.hasPrefix(InstagramClient.Constants.REDIRECT_URI) {
            //let range: Range<String.Index> = requestURLString.range(of: "#access_token=")!
            let accessToken = requestURLString.range(of: "#access_token=")
            print("**** ACCESS TOKEN = \(String(describing: accessToken))")
            
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "MainTabBarController") as! UITabBarController
            //controller.delegate = self as? UITabBarControllerDelegate
            //let vc = MainTabBarController()
            
            
            self.present(controller, animated: true, completion: nil)
            //handleAuth(authToken: requestURLString.substring(from: range.upperBound))
            return false;
        }
        return true
        //return checkRequestForCallbackURL(request: request)
    }
    
}
/*
extension InstagramLoginViewController: InstagramLogout {
    func performLogout() {
        let logoutRequest = URLRequest(url: URL(string: "https://instagram.com/accounts/logout")! as URL)//logout from webview browser
        webView.loadRequest(logoutRequest)
    }
}
*/

class InstagramLoginViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var isLoggedIn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (!isLoggedIn) {
            print("**** Try to logged in")
            
            showInstagramLogin()
            isLoggedIn = true
        }
        else {
            print("**** IS LOGGED IN")
            let logoutRequest = URLRequest(url: URL(string: "https://instagram.com/accounts/logout")! as URL)
            webView.loadRequest(logoutRequest)
        }
        
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
