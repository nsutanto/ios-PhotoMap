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
import MapKit
import CoreData
extension InstagramLoginViewController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let requestURLString = (request.url?.absoluteString)! as String
        
        if requestURLString.hasPrefix(InstagramClient.Constants.REDIRECT_URI) {
            
            // Get User Token
            assignToken(requestURLString)
            
            // Get User Info, and images
            getUserInfo()
            
            showMainTabController()
            // return false, we do not want to show the web. We just need to get the token
            return false;
        }
        return true
    }
}

class InstagramLoginViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var isLoggedIn = false
    var isInvalidToken = false
    var userInfo : UserInfo?
    // Initialize core data stack
    var coreDataStack: CoreDataStack?
    var mapViewController: MapViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize core data stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        coreDataStack = delegate.stack
        
        webView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if (!isLoggedIn) {
            showInstagramLogin()
            isLoggedIn = true
        }
        else {
            let logoutRequest = URLRequest(url: URL(string: "https://instagram.com/accounts/logout")! as URL)
            webView.loadRequest(logoutRequest)
            
            // Delete all data
            deleteAllUserData()
            
            InstagramClient.sharedInstance().accessToken = nil
            
            if (!isInvalidToken) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    private func showInstagramLogin() {
        
        let url = InstagramClient.sharedInstance().getLoginURL()
        let request = URLRequest(url: url)
        webView.loadRequest(request)
    }
    
    private func assignToken(_ requestURLString: String) {
        let range = requestURLString.range(of: "#access_token=")
        
        // the end index of "#access_token="
        let upperIndex = range!.upperBound
        // Get the access token, it starts from the upper index to the end of string
        let accessToken = String(requestURLString[upperIndex...])
        
        // Assign client access token
        InstagramClient.sharedInstance().accessToken = accessToken
    }
    
    private func showMainTabController() {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
        self.present(controller, animated: true, completion: nil)
    }
    
    private func getUserInfo() {
        InstagramClient.sharedInstance().getUserInfo(completionHandlerUserInfo: { (userInfo, error ) in
            if (error == nil) {
                self.userInfo = userInfo!
                DispatchQueue.main.async {
                    self.getUserImages(userInfo!)
                }
            }
            else {
                self.alertError("Fail to get user info")
            }
        })
    }
    
    private func getUserImages(_ userInfo: UserInfo) {
        
        ImageLocationUtil.sharedInstance().getUserImages(userInfo, completionHandlerUserImages: {(images, error) in
            if (error != nil) {
                self.alertError("Fail to get user images")
            }
        })
    }
    
    private func deleteAllUserData() {
        let requestImage: NSFetchRequest<Image> = Image.fetchRequest()
        if let result = try? coreDataStack?.context.fetch(requestImage) {
            for image in result! {
                coreDataStack?.context.delete(image)
            }
        }
        
        let requestCityEntity: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        if let result = try? coreDataStack?.context.fetch(requestCityEntity) {
            for cityEntity in result! {
                coreDataStack?.context.delete(cityEntity)
            }
        }
        
        let requestCountryEntity: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
        if let result = try? coreDataStack?.context.fetch(requestCountryEntity) {
            for countryEntity in result! {
                coreDataStack?.context.delete(countryEntity)
            }
        }
        
        
        let requestUserInfo: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        if let result = try? coreDataStack?.context.fetch(requestUserInfo) {
            for userInfo in result! {
                coreDataStack?.context.delete(userInfo)
            }
        }
        
        coreDataStack?.save()
    }
    
    private func alertError(_ alertMessage: String) {
        performUIUpdatesOnMain {
            let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}
