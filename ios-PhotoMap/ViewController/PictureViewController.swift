//
//  MediaViewController.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 11/7/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//

import UIKit
import CoreData

extension PictureViewController: UICollectionViewDataSource {
    
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath as IndexPath) as! PictureCollectionViewCell
        
        performUIUpdatesOnMain {
            cell.imageView.image = nil
            cell.activityIndicator.startAnimating()
        }
        
        let image = fetchedResultsController.object(at: indexPath)
        
        // This should be triggered after download image anyway that the fetchresultscontroller will fire event to update the UI
        if let imageData = image.imageData {
            performUIUpdatesOnMain {
                cell.imageView.image = UIImage(data: imageData as Data)
                cell.activityIndicator.stopAnimating()
            }
        }
        else {
            // Download image
            let task = clientUtil.downloadImage(imageURL: image.imageURL!, completionHandler: { (imageData, error) in
                if (error == nil) {
                    
                    performUIUpdatesOnMain {
                        // Note : No need to assign the cell image here. The core data save will trigger
                        // the event to update this cell anyway later.
                        cell.activityIndicator.stopAnimating()
                    }
                    
                    self.coreDataStack?.context.perform {
                        image.imageData = imageData as NSData?
                    }
                } else {
                    self.alertError("Fail to download image")
                }
            })
            cell.taskToCancelifCellIsReused = task
            
        }
        
        return cell
    }
}

extension PictureViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        // Reset indexes
        insertIndexes.removeAll()
        deleteIndexes.removeAll()
        updateIndexes.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // Assigned all the indexes so that we can update the cell accordingly
        
        switch (type) {
        case .insert:
            insertIndexes.append(newIndexPath!)
        case .delete:
            deleteIndexes.append(indexPath!)
        case .update:
            updateIndexes.append(indexPath!)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.performBatchUpdates( {
            self.collectionView.insertItems(at: insertIndexes)
            self.collectionView.deleteItems(at: deleteIndexes)
            self.collectionView.reloadItems(at: updateIndexes)
        }, completion: nil)
    }
}

extension PictureViewController: UICollectionViewDelegate {
    
    // When user select one of the cell
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let image = fetchedResultsController.object(at: indexPath)

        let vc = self.storyboard!.instantiateViewController(withIdentifier: "DetailViewController") as! DetailViewController
        
        let images = fetchedResultsController.fetchedObjects
        vc.curentIndex = indexPath.row
        vc.images = images
        vc.imageEntity = image
        
        self.navigationController?.pushViewController(vc, animated: false)
    }
}


class PictureViewController: UIViewController {
    
    @IBOutlet weak var locationTitle: UINavigationItem!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    // Selected Location from previous navigation controller
    // Core Data Stack
    var coreDataStack: CoreDataStack?
    // Insert, Delete, and Update index for the fetched results controller
    var insertIndexes = [IndexPath]()
    var deleteIndexes = [IndexPath]()
    var updateIndexes = [IndexPath]()
    var selectedIndexes = [IndexPath]()
    var selectedCity: CityEntity?
    var selectedCountry: CountryEntity?
    let clientUtil = ClientUtil()
    
    lazy var fetchedResultsController: NSFetchedResultsController<Image> = {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        if (selectedCity != nil) {
            request.predicate = NSPredicate(format: "imageToCity == %@", self.selectedCity!)
        }
        else {
            request.predicate = NSPredicate(format: "imageToCountry == %@", self.selectedCountry!)
        }
        
        let moc = coreDataStack?.context
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request as! NSFetchRequest<Image>,
                                                                  managedObjectContext: moc!,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        return fetchedResultsController
    }()
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize core data stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        coreDataStack = delegate.stack
        
        // Initialize delegate
        collectionView.delegate = self
        fetchedResultsController.delegate = self
        
        // Init Layout
        initLayout(size: view.frame.size)
        // Initialize fetched results controller from core data stack
        performFetch()
        // Set title
        if (selectedCity != nil) {
            locationTitle.title = (selectedCity?.city)! + ", " + (selectedCity?.state)!
        }
        else {
            locationTitle.title = (selectedCountry?.country)!
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        selectedCity = nil
        selectedCountry = nil
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        initLayout(size: size)
    }
    
    // Mark : Init Layout
    func initLayout(size: CGSize) {
        let space: CGFloat = 3.0
        let dimension: CGFloat
        
        dimension = (size.width - (2 * space)) / 3.0
        
        flowLayout?.minimumInteritemSpacing = space
        flowLayout?.minimumLineSpacing = space
        flowLayout?.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    private func alertError(_ alertMessage: String) {
        performUIUpdatesOnMain {
            let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
