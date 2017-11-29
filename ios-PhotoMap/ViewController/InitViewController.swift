//
//  ViewController.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 10/26/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//

import UIKit
import CoreData

class InitViewController: UIViewController {
    
    var coreDataStack: CoreDataStack?
    var userToken: String?
    var userInfo: UserInfo?
    var needToLogout: Bool?
    
    @IBOutlet weak var loginText: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        coreDataStack = delegate.stack
    
        performUIStyle()
        
        needToLogout = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if user is already login
        checkUserInfo()
        
        if userToken != nil {
            loginButton.isHidden = true
            loginText.isHidden = true
        } else {
            loginButton.isHidden = false
            loginText.isHidden = false
        }
    }
    
    private func performUIStyle() {
        loginButton.layer.cornerRadius = 10
        loginButton.clipsToBounds = true
    }
    
    private func checkUserInfo() {
        // Check if user has the token already. Then no need to show the web login.
        let request: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        
        if let result = try? coreDataStack?.context.fetch(request) {
            userInfo = result?.first
            if let userInfo = userInfo {
                if userInfo.token != nil {
                    userToken = userInfo.token
                    InstagramClient.sharedInstance().accessToken = userToken
                }
                else {
                    userToken = nil
                }
            }
            else {
                userToken = nil
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        // Check if user has the token already. Then no need to show the web login.
        if userToken != nil {
            validateToken()
        }
    }
    
    @IBAction func performLogin(_ sender: Any) {
        let instagramLoginViewController = self.storyboard!.instantiateViewController(withIdentifier: "InstagramLoginViewController") as! InstagramLoginViewController
        instagramLoginViewController.isLoggedIn = needToLogout!
        instagramLoginViewController.isInvalidToken = needToLogout!
        self.present(instagramLoginViewController, animated: true, completion: nil)
    }
    
    
    private func validateToken() {
        InstagramClient.sharedInstance().getUserInfo { (userInfo, error) in
            if (error == nil) {
                // user token is valid
                performUIUpdatesOnMain {
                    let controller = self.storyboard!.instantiateViewController(withIdentifier: "InstagramLoginViewController") as! InstagramLoginViewController
                    
                    ImageLocationUtil.sharedInstance().getUserImages(userInfo!, completionHandlerUserImages: {(images, error) in
                        
                        self.present(controller, animated: true, completion: nil)
                    
                    })
                }
            }
            else {
                // user token is not valid.. can be expired.. so need to login again
                do {
                    try self.coreDataStack?.dropAllData()
                } catch {
                    print("Error droping all objects in DB")
                }
                
                self.userToken = nil
                self.coreDataStack?.save()
                InstagramClient.sharedInstance().accessToken = nil
                self.needToLogout = true
                
                performUIUpdatesOnMain {
                    self.loginButton.isHidden = false
                    self.loginText.isHidden = false
                }
            }
        }
    }
}

