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
    
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        coreDataStack = delegate.stack
        
        // Check if user is already login
        checkUserInfo()
        
        performUIStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if userToken != nil {
            loginButton.isHidden = true
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
            if let userInfo = result?.first {
                if userInfo.token != nil {
                    userToken = userInfo.token
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        // Check if user has the token already. Then no need to show the web login.
        if userToken != nil {
                    
            let controller = self.storyboard!.instantiateViewController(withIdentifier: "InstagramLoginViewController") as! InstagramLoginViewController
            
            self.present(controller, animated: true, completion: nil)
        }
    }
}

