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
        
        let defaults = UserDefaults.standard
        defaults.set(self.mapView.region.center.latitude, forKey: STRING_LATITUDE)
        defaults.set(self.mapView.region.center.longitude, forKey: STRING_LONGITUDE)
        defaults.set(self.mapView.region.span.latitudeDelta, forKey: STRING_LATITUDE_DELTA)
        defaults.set(self.mapView.region.span.longitudeDelta, forKey: STRING_LONGITUDE_DELTA)
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "PictureViewController") as! PictureViewController
            
            switch segmentationControl.selectedSegmentIndex
            {
            case 0:
                if let annotation = view.annotation {
                    let countryString = annotation.title!
                    
                    ImageLocationUtil.sharedInstance().getCountryEntity(countryString!, completionHandlerLocations: { (countryEntity) in
                        if (countryEntity == nil) {
                            self.alertError("Fail to get country")
                        }
                        else {
                            vc.selectedCountry = countryEntity
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    })
                }
                
            case 1:
                if let annotation = view.annotation {
                    let annotationTitle = annotation.title!
                    let locationArray = annotationTitle?.components(separatedBy: ",")
                    let city: String = locationArray![0]
                    var state: String = locationArray![1]
                    // remove space
                    state.remove(at: state.startIndex)
                 
                    ImageLocationUtil.sharedInstance().getCityEntity(city, state, completionHandlerLocations: { (cityEntity) in
                        if (cityEntity == nil) {
                            self.alertError("Fail to get city")
                        }
                        else {
                            vc.selectedCity = cityEntity
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    })
                }
            default:
                break
            }
            
            
        }
    }
}

extension MapViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.loadMap()
        }
    }
}

extension MapViewController : ImageLocationUtilDelegate {
    func didFetchImage() {
        performUIUpdatesOnMain {
            self.loadMap()
        }
    }
}

class MapViewController: UIViewController {

    var coreDataStack: CoreDataStack?
    let STRING_LATITUDE = "Latitude"
    let STRING_LONGITUDE = "Longitude"
    let STRING_LATITUDE_DELTA = "LatitudeDelta"
    let STRING_LONGITUDE_DELTA = "LongitudeDelta"
    let STRING_FIRST_LAUNCH = "FirstLaunch"
    var countryEntities = [CountryEntity]()
    var cityEntities = [CityEntity]()
    
    let serialQueue = DispatchQueue(label: "com.nsutanto.PhotoMap", qos: .utility)
    
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
    
    lazy var fetchedResultsControllerCountry: NSFetchedResultsController<CountryEntity> = {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CountryEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "country", ascending: true)]
        
        let moc = coreDataStack?.context
        let fetchedResultsControllerCountry = NSFetchedResultsController(fetchRequest: request as! NSFetchRequest<CountryEntity>,
                                                                      managedObjectContext: moc!,
                                                                      sectionNameKeyPath: nil,
                                                                      cacheName: nil)
        return fetchedResultsControllerCountry
    }()
    
    func performFetchCountry() {
        do {
            try fetchedResultsControllerCountry.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        ImageLocationUtil.sharedInstance().imageLocationDelegate = self
        
        // Initialize core data stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        coreDataStack = delegate.stack
        
        mapView.delegate = self
        //fetchedResultsControllerCity.delegate = self
        //fetchedResultsControllerCountry.delegate = self
        
        performUIUpdatesOnMain {
            self.initMapSetting()
            self.loadMap()
        }
    }
    
    func loadMap() {
        
        switch segmentationControl.selectedSegmentIndex
        {
        case 0:
            loadCountries()
        case 1:
            loadCities()
        default:
            break
        }
    }
    
    private func loadCountries() {
        let request: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
        if let result = try? self.coreDataStack?.context.fetch(request) {
            countryEntities = result!
            if countryEntities.count > 0 {
                performUpdateMapCountry(0)
            }
        }
    }
    
    private func loadCities() {
        let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        if let result = try? self.coreDataStack?.context.fetch(request) {
            cityEntities = result!
            if cityEntities.count > 0 {
                performUpdateMapCity(0)
            }
        }
    }
    
    private func performUpdateMapCountry(_ index: Int) {
        
        let countryEntity = countryEntities[index]
        
        if countryEntity.latitude != 0 && countryEntity.longitude != 0 {
            print("********* Exist country : \(countryEntity.country)")

            addMapAnnotation(countryEntity.latitude, countryEntity.longitude, countryEntity.country!)
            
            if (index < countryEntities.count - 1) {
                let nextIndex = index + 1
                performUpdateMapCountry(nextIndex)
            }
        } else {
            print("********* Create country : \(countryEntity.country)")
            updateMapView(countryEntity.country!) {(latitude, longitude) in
                if (latitude != nil && longitude != nil) {
                    self.coreDataStack?.context.perform {
                        countryEntity.latitude = latitude!
                        countryEntity.longitude = longitude!
                        self.coreDataStack?.save()
                    }
                }
                
                if (index < self.countryEntities.count - 1) {
                    let nextIndex = index + 1
                    self.performUpdateMapCountry(nextIndex)
                }
            }
        }
    }
    
    func performUpdateMapCity(_ index: Int) {
        
        let cityEntity = cityEntities[index]
        let location = cityEntity.city! + ", " + cityEntity.state!
        if cityEntity.latitude != 0 && cityEntity.longitude != 0 {
            print("********* Exist city : \(cityEntity.city)")
            addMapAnnotation(cityEntity.latitude, cityEntity.longitude, location)
            
            if (index < cityEntities.count - 1) {
                let nextIndex = index + 1
                performUpdateMapCity(nextIndex)
            }
        } else {
            print("********* Create city : \(cityEntity.city)")
            updateMapView(location) {(latitude, longitude) in
                print("****** Get longitude and latitude")
                if (latitude != nil && longitude != nil) {
                    self.coreDataStack?.context.perform {
                        cityEntity.latitude = latitude!
                        cityEntity.longitude = longitude!
                        self.coreDataStack?.save()
                    }
                }
                if (index < self.cityEntities.count - 1) {
                    let nextIndex = index + 1
                    self.performUpdateMapCity(nextIndex)
                }
            }
        }
    }
    
    func updateMapView(_ location: String, completionHandler: @escaping (_ latitude: Double?, _ longitude: Double?) -> Void) {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location) { (placeMarks, error) in
            
            if (error == nil) {
                // placeMarks can be multiple places.. so how about try the first one?
                if ((placeMarks?.count)! == 1) {
                    let placeMark = placeMarks![0]
                    let longitude = placeMark.location?.coordinate.longitude
                    let latitude = placeMark.location?.coordinate.latitude
                    
                    self.addMapAnnotation(latitude!, longitude!, location)
                    completionHandler(latitude!, longitude!)
                }
                else if ((placeMarks?.count)! == 0) {
                    self.alertError("Location is not found.")
                    completionHandler(nil, nil)
                }
                else {
                    self.alertError("Multiple locations found.")
                    completionHandler(nil, nil)
                }
            }
            else {
                // https://stackoverflow.com/questions/29087660/error-domain-kclerrordomain-code-2-the-operation-couldn-t-be-completed-kclerr
                self.alertError("Error getting location. Please wait 1 minute before refreshing the map or re-start the app. Sorry Apple limit # of location requests..")
                completionHandler(nil, nil)
            }
        }
    }
    
    private func addMapAnnotation(_ latitude: Double, _ longitude: Double, _ location: String) {
        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Set the annotation
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = location
        
        performUIUpdatesOnMain {
            self.mapView.addAnnotation(annotation)
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
        performUIUpdatesOnMain {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.loadMap()
        }
    }

    private func initMapSetting() {
        
        let defaults = UserDefaults.standard
        if UserDefaults.standard.bool(forKey: STRING_FIRST_LAUNCH) {
            let centerLatitude  = defaults.double(forKey: STRING_LATITUDE)
            let centerLongitude = defaults.double(forKey: STRING_LONGITUDE)
            let latitudeDelta   = defaults.double(forKey: STRING_LATITUDE_DELTA)
            let longitudeDelta  = defaults.double(forKey: STRING_LONGITUDE_DELTA)
            
            let centerCoordinate = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
            let spanCoordinate = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            let region = MKCoordinateRegion(center: centerCoordinate, span: spanCoordinate)
            
            performUIUpdatesOnMain {
                self.mapView.setRegion(region, animated: true)
            }
        } else {
            defaults.set(true, forKey: STRING_FIRST_LAUNCH)
        }
    }}
