//
//  CellCancelTask.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 11/8/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//

import Foundation
import UIKit

// https://discussions.udacity.com/t/retrieving-images-from-flickr/177208
// Task to cancel from Favorite Actors app
class CellCancelTask : UICollectionViewCell {
    
    var taskToCancelifCellIsReused: URLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }
}
