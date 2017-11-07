//
//  MapViewController.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 10/27/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//

import UIKit
import CoreData
import MapKit

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // Save the region everytime we change the map
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        /*
        let defaults = UserDefaults.standard
        defaults.set(self.mapView.region.center.latitude, forKey: STRING_LATITUDE)
        defaults.set(self.mapView.region.center.longitude, forKey: STRING_LONGITUDE)
        defaults.set(self.mapView.region.span.latitudeDelta, forKey: STRING_LATITUDE_DELTA)
        defaults.set(self.mapView.region.span.longitudeDelta, forKey: STRING_LONGITUDE_DELTA)
        */
    }
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        /*
        let coordinate = view.annotation?.coordinate
        if (onEdit) {
            // Delete
            for location in locations {
                if location.latitude == (coordinate!.latitude) && location.longitude == (coordinate!.longitude) {
                    
                    let annotationToRemove = view.annotation
                    self.mapView.removeAnnotation(annotationToRemove!)
                    coreDataStack?.context.delete(location)
                    coreDataStack?.save()
                    
                    break
                }
            }
        } else {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "PictureViewControllerID") as! PictureViewController
            
            // Grab the location object from Core Data
            let location = self.getLocation(longitude: coordinate!.longitude, latitude: coordinate!.latitude)
            
            vc.selectedLocation = location
            vc.totalPageNumber = location?.value(forKey: "totalFlickrPages") as! Int
            
            self.navigationController?.pushViewController(vc, animated: false)
        }*/
    }
}

extension MapViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("**** Will Change Content")
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        // Assigned all the indexes so that we can update the cell accordingly
        
        /*
        switch (type) {
        case .insert:
        case .delete:
        case .update:
        default:
            break
        }
        */
        print("**** controller did change 1")
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("**** controller did change 2")
    }
}

class MapViewController: UIViewController {

    var coreDataStack: CoreDataStack?
    
    @IBOutlet weak var mapView: MKMapView!
    
    lazy var fetchedResultsController: NSFetchedResultsController<Image> = {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CountryEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "country", ascending: true)]
        
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
        
        mapView.delegate = self
        
        fetchedResultsController.delegate = self
        
        performFetch()
        print("***** Map did load done")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("***** Map view will appear")
    }
    
    func loadMap() {
        print("***** Load Countries")
        loadCountries()
        loadCities()
    }
    
    private func loadCountries() {
        let request: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
        if let result = try? self.coreDataStack?.context.fetch(request) {
            
            if (result == nil) {
                print("***** Country is nil")
            }
            
            //var annotationsArray = [MKPointAnnotation]()
            //for location in result! {
                /*
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = location.latitude
                annotation.coordinate.longitude = location.longitude
                annotationsArray.append(annotation)
                locations.append(location)
                */
            //}
            
            //performUIUpdatesOnMain {
            //    self.mapView.addAnnotations(annotationsArray)
            //}
            
        }
    }
    
    private func loadCities() {
        let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        if let result = try? self.coreDataStack?.context.fetch(request) {
            
            if (result == nil) {
                print("***** City is nil")
            }
            
            //var annotationsArray = [MKPointAnnotation]()
            //for location in result! {
            /*
             let annotation = MKPointAnnotation()
             annotation.coordinate.latitude = location.latitude
             annotation.coordinate.longitude = location.longitude
             annotationsArray.append(annotation)
             locations.append(location)
             */
            //}
            
            //performUIUpdatesOnMain {
            //    self.mapView.addAnnotations(annotationsArray)
            //}
            
        }
    }

}
