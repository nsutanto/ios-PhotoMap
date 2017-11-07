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

class MapViewController: UIViewController {

    var coreDataStack: CoreDataStack?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize core data stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        coreDataStack = delegate.stack
        
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadMap() {
        print("***** Load Countries")
        loadCountries()
    }
    
    private func loadCountries() {
        let request: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
        if let result = try? self.coreDataStack?.context.fetch(request) {
            
            if (result == nil) {
                print("***** Country is nil")
            }
            
            var annotationsArray = [MKPointAnnotation]()
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
