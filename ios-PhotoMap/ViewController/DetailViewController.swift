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
    var images: [Image]!
    var curentIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setImage(imageEntity)
        initSwipeGesture()
    }
    
    private func setImage(_ imageEntity: Image) {
        imageText.numberOfLines = 0
        imageView.image = UIImage(data: imageEntity.imageData! as Data)
        imageText.text = imageEntity.text
    }
    
    private func initSwipeGesture() {
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.performSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.performSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view.addGestureRecognizer(swipeLeft)
    }
    
    @IBAction func performShare(_ sender: Any) {
        let controller = UIActivityViewController(activityItems: [imageView.image!], applicationActivities: nil)
        controller.popoverPresentationController?.sourceView = self.view
        controller.completionWithItemsHandler = {(activity, completed, items, error) in
            
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func performSwipeGesture(_ recognizer: UIGestureRecognizer) {
        if let swipeGesture = recognizer as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
               
                if (curentIndex > 0) {
                    let index = curentIndex - 1
                    curentIndex = index
                    let imageEntity = images[index]
                    setImage(imageEntity)
                }
            case UISwipeGestureRecognizerDirection.left:
                
                if (curentIndex < images.count - 1) {
                    let index = curentIndex + 1
                    curentIndex = index
                    let imageEntity = images[index]
                    setImage(imageEntity)
                }
                
            default:
                break
            }
        }
    }
    
}
