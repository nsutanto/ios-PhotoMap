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
    
    @IBOutlet weak var loginText: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        coreDataStack = delegate.stack
    
        performUIStyle()
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
                    
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "InstagramLoginViewController") as! InstagramLoginViewController
            
            ImageLocationUtil.sharedInstance().getUserImages(userInfo!, completionHandlerUserImages: {(images, error) in
                performUIUpdatesOnMain {
                    self.present(controller, animated: true, completion: nil)
                }
            })
        }
    }
}

