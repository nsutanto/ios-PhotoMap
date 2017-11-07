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
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        loadMap()
    }
}

class MapViewController: UIViewController {

    var coreDataStack: CoreDataStack?
    
    @IBOutlet weak var mapView: MKMapView!
    
    lazy var fetchedResultsControllerCity: NSFetchedResultsController<CityEntity> = {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CityEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "city", ascending: true)]
        
        let moc = coreDataStack?.context
        let fetchedResultsControllerCity = NSFetchedResultsController(fetchRequest: request as! NSFetchRequest<CityEntity>,
                                                                  managedObjectContext: moc!,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        return fetchedResultsControllerCity
    }()
    
    func performFetchCity() {
        do {
            try fetchedResultsControllerCity.performFetch()
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
        
        fetchedResultsControllerCity.delegate = self
        
        performFetchCity()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadMap() {
        loadCountries()
        loadCities()
    }
    
    private func loadCountries() {
        let request: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
        if let result = try? self.coreDataStack?.context.fetch(request) {
            
            //var annotationsArray = [MKPointAnnotation]()
            for countryEntity in result! {
                print(countryEntity.country!)
                /*
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = location.latitude
                annotation.coordinate.longitude = location.longitude
                annotationsArray.append(annotation)
                locations.append(location)
                */
            }
            
            //performUIUpdatesOnMain {
            //    self.mapView.addAnnotations(annotationsArray)
            //}
            
        }
    }
    
    private func loadCities() {
        let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        if let result = try? self.coreDataStack?.context.fetch(request) {
            
            //var annotationsArray = [MKPointAnnotation]()
            for cityEntity in result! {
                print(cityEntity.city!)
                /*
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = location.latitude
                annotation.coordinate.longitude = location.longitude
                annotationsArray.append(annotation)
                locations.append(location)
 */
             
            }
            
            //performUIUpdatesOnMain {
            //    self.mapView.addAnnotations(annotationsArray)
            //}
            
        }
    }
}
