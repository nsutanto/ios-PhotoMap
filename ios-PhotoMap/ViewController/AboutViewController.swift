//
//  AboutViewController.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 10/27/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//

import UIKit
import CoreData

class AboutViewController: UIViewController {

    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var labelFullName: UILabel!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    var coreDataStack: CoreDataStack?
    let clientUtil = ClientUtil()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performUIStyle()
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        coreDataStack = delegate.stack
        
        loadUserInfo()
    }
    
    private func performUIStyle() {
        logoutButton.layer.cornerRadius = 10
        logoutButton.clipsToBounds = true
        
        profilePicture.layer.borderWidth = 1
        profilePicture.layer.masksToBounds = false
        profilePicture.layer.borderColor = UIColor.black.cgColor
        profilePicture.layer.cornerRadius = profilePicture.frame.height/2
        profilePicture.clipsToBounds = true
    }
    
    private func loadUserInfo() {
        let request: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        
        if let result = try? coreDataStack?.context.fetch(request) {
            let userInfo = result?.first
            
            labelFullName.text = userInfo?.fullName
            labelUserName.text = userInfo?.userName
            
            if let imageData = userInfo?.profilePictureData {
                performUIUpdatesOnMain {
                    self.profilePicture.image = UIImage(data: imageData as Data)
                }
            }
            else {
                // Download image
                _ = clientUtil.downloadImage(imageURL: (userInfo?.profilePictureURL!)!, completionHandler: { (imageData, error) in
                    if (error == nil) {
                        
                        performUIUpdatesOnMain {
                            self.profilePicture.image = UIImage(data: imageData!)
                        }
                        
                        self.coreDataStack?.context.perform {
                            userInfo?.profilePictureData = imageData as NSData?
                        }
                    } else {
                        self.alertError("Fail to download image")
                    }
                })
            }
        }
    }
    
    @IBAction func performLogout(_ sender: Any) {
        
        self.coreDataStack?.context.perform {
            let request: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
            
            if let result = try? self.coreDataStack?.context.fetch(request) {
                let userInfo = result?.first
                userInfo?.token = nil
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func alertError(_ alertMessage: String) {
        performUIUpdatesOnMain {
            let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
