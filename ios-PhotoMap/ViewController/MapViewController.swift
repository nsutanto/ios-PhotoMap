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
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
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
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "PictureViewController") as! PictureViewController
            
            let coordinate = view.annotation?.coordinate
            
            switch segmentationControl.selectedSegmentIndex
            {
            case 0:
                getCountryEntity(latitude: (coordinate?.latitude)!, longitude: (coordinate?.longitude)!, completionHandlerLocations: { (countryEntity) in
                    vc.selectedCountry = countryEntity
                    self.navigationController?.pushViewController(vc, animated: true)
                })
            case 1:
                getCityEntity(latitude: (coordinate?.latitude)!, longitude: (coordinate?.longitude)!, completionHandlerLocations: { (cityEntity) in
                    vc.selectedCity = cityEntity
                    self.navigationController?.pushViewController(vc, animated: true)
                })
            default:
                break
            }
            
            
        }
    }
}

extension MapViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        loadMap()
    }
}

class MapViewController: UIViewController {

    var coreDataStack: CoreDataStack?
    
    @IBOutlet weak var segmentationControl: UISegmentedControl!
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
        loadMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadMap() {
        performUIUpdatesOnMain {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
        switch segmentationControl.selectedSegmentIndex
        {
        case 0:
            loadCountries()
        case 1:
            loadCities()
        default:
            print("***** Load default")
            break
        }
    }
    
    private func loadCountries() {
        let request: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
        if let result = try? self.coreDataStack?.context.fetch(request) {
            
            for countryEntity in result! {
                print(countryEntity.country!)
                for countryEntity in result! {
                    updateMapView(countryEntity.country!)
                }
            }
        }
    }
    
    private func loadCities() {
        let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        if let result = try? self.coreDataStack?.context.fetch(request) {
            
            for cityEntity in result! {
                let location = cityEntity.city! + ", " + cityEntity.state!
                updateMapView(location)
            }
        }
    }
    
    func updateMapView(_ location: String) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location) { (placeMarks, error) in
            
            if (error == nil) {
                // placeMarks can be multiple places.. so how about try the first one?
                if ((placeMarks?.count)! == 1) {
                    let placeMark = placeMarks![0]
                    let longitude = placeMark.location?.coordinate.longitude
                    let latitude = placeMark.location?.coordinate.latitude
                    
                    // The lat and long are used to create a CLLocationCoordinates2D instance.
                    let coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
                    
                    // Set the annotation
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = coordinate
                    annotation.title = location
                    
                    performUIUpdatesOnMain {
                        self.mapView.addAnnotation(annotation)
                    }
                }
                else if ((placeMarks?.count)! == 0) {
                    self.alertError("Location is not found.")
                }
                else {
                    self.alertError("Multiple locations found.")
                }
            }
            else {
                self.alertError("Error getting location.")
            }
        }
    }
    
    private func alertError(_ alertMessage: String) {
        performUIUpdatesOnMain {
            let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func onSegControlValueChanged(_ sender: Any) {
        loadMap();
    }

    private func getCityEntity(latitude: Double, longitude: Double, completionHandlerLocations: @escaping(_ cityEntity: CityEntity?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                self.alertError("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                
                let city = pm.locality
                let state = pm.administrativeArea
                
                let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
                let predicateCity = NSPredicate(format: "city == %@", city!)
                let predicateState = NSPredicate(format: "state == %@", state!)
                let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicateCity,predicateState])
                
                request.predicate = predicateCompound
                let cityEntityResult = try? self.coreDataStack?.context.fetch(request)
                completionHandlerLocations(cityEntityResult??.first)
            }
            else {
                completionHandlerLocations(nil)
            }
        })
    }
    
    private func getCountryEntity(latitude: Double, longitude: Double, completionHandlerLocations: @escaping(_ countryEntity: CountryEntity?) -> Void) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                self.alertError("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                
                let country = pm.country
                
                let request: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
                request.predicate = NSPredicate(format: "country == %@", country!)
                
                let countryEntityResult = try? self.coreDataStack?.context.fetch(request)
                completionHandlerLocations(countryEntityResult??.first)
            }
            else {
                completionHandlerLocations(nil)
            }
        })
    }
}
