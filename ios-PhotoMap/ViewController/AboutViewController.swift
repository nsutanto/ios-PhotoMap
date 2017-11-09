//
//  AboutViewController.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 10/27/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func performLogout(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func performSegue(_ sender: Any) {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "PictureViewController") as! PictureViewController
        
        // Nick : Need to do this for navigation controller. otherwise it will not display the navigation bar
        self.navigationController?.pushViewController(vc, animated: false)
    }
}
