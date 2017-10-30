//
//  AboutViewController.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 10/27/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    /*
    var delegate: isAbleToPassData
    
    func viewWillDisappear() {
        super.viewWillDisappear(true)
        delegate.pass(data: "someData") //call the func in the previous vc
    }
     */
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("***** AboutViewController view did load")
        // Do any additional setup after loading the view.
    }
    
    @IBAction func performLogout(_ sender: Any) {
        //let logoutRequest = URLRequest(url: URL(string: "https://instagram.com/accounts/logout")! as URL)//logout from webview browser
        //webView.loadRequest(logoutRequest)
        //let url = URL(string: "https://instagram.com/accounts/logout")
        
        //let task = URLSession.shared.dataTask(with: url!) {(data, response, error) in
            //print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue) as Any)
        //    self.dismiss(animated: true, completion: nil)
        //}
        
        //task.resume()
        
        //let loginVC: InstagramLoginViewController = InstagramLoginViewController()
        //loginVC.isLoggedIn = true
        //self.present(loginVC, animated: true, completion: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
}
