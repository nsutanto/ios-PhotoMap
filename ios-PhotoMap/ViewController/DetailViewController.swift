//
//  DetailViewController.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 11/7/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageText: UILabel!
    
    var imageEntity: Image!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageText.numberOfLines = 0
        imageView.image = UIImage(data: imageEntity.imageData! as Data)
        imageText.text = imageEntity.text
    }
    @IBAction func performShare(_ sender: Any) {
        let controller = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        controller.popoverPresentationController?.sourceView = self.view
        controller.completionWithItemsHandler = {(activity, completed, items, error) in
            
        }
        self.present(controller, animated: true, completion: nil)
    }
}
