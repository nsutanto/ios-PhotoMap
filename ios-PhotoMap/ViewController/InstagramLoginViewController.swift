//
//  InstagramLoginViewController.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 10/27/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//

import Foundation
import UIKit
import WebKit
import MapKit
import CoreData
extension InstagramLoginViewController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        let requestURLString = (request.url?.absoluteString)! as String
        
        if requestURLString.hasPrefix(InstagramClient.Constants.REDIRECT_URI) {
            
            // Get User Token
            assignToken(requestURLString)
            
            // Get User Info, and images
            getUserInfo()
            
            showMainTabController()
            // return false, we do not want to show the web. We just need to get the token
            return false;
        }
        return true
    }
}

class InstagramLoginViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    var isLoggedIn = false
    var images = [Image]()
    var userInfo = UserInfo()
    // Initialize core data stack
    var coreDataStack: CoreDataStack?
    var mapViewController: MapViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize core data stack
        let delegate = UIApplication.shared.delegate as! AppDelegate
        coreDataStack = delegate.stack
        
        webView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if (!isLoggedIn) {
            showInstagramLogin()
            isLoggedIn = true
        }
        else {
            let logoutRequest = URLRequest(url: URL(string: "https://instagram.com/accounts/logout")! as URL)
            webView.loadRequest(logoutRequest)
            do {
                try coreDataStack?.dropAllData()
            } catch {
                print("Error droping all objects in DB")
            }
            InstagramClient.sharedInstance().accessToken = nil
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func showInstagramLogin() {
        
        let url = InstagramClient.sharedInstance().getLoginURL()
        let request = URLRequest(url: url)
        webView.loadRequest(request)
    }
    
    private func assignToken(_ requestURLString: String) {
        let range = requestURLString.range(of: "#access_token=")
        
        // the end index of "#access_token="
        let upperIndex = range!.upperBound
        // Get the access token, it starts from the upper index to the end of string
        let accessToken = String(requestURLString[upperIndex...])
        
        // Assign client access token
        InstagramClient.sharedInstance().accessToken = accessToken
    }
    
    private func showMainTabController() {
        let controller = self.storyboard!.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
        
        self.present(controller, animated: true, completion: nil)
    }
    
    private func getUserInfo() {
        InstagramClient.sharedInstance().getUserInfo(completionHandlerUserInfo: { (userInfo, error ) in
            if (error == nil) {
                self.userInfo = userInfo!
                self.getUserImages()
            }
            else {
                self.alertError("Fail to get user info")
            }
        })
    }
    
    private func getUserImages() {
        InstagramClient.sharedInstance().getImages(completionHandlerGetImages: { (images, error) in
            if (error == nil) {
                self.images = images!
                self.getImageLocation()
            }
            else {
                self.alertError("Fail to get user images")
            }
        })
    }
    
    private func getImageLocation() {
        performReverseGeoLocation(completionHandlerLocations: { (cities, countries) in
            self.coreDataStack?.save()
        })
    }
    
    private func performReverseGeoLocation(completionHandlerLocations: @escaping(_ cities: [String], _ countries: [String]) -> Void) {
        // https://stackoverflow.com/questions/47129345/swift-how-to-perform-task-completion/47130196#47130196
        let dispatchGroup = DispatchGroup()
        var cities = [String]()
        var countries = [String]()
        
        self.images.forEach { (image) in
            dispatchGroup.enter()
            let longitude = image.longitude
            let latitude = image.latitude
            
            let location = CLLocation(latitude: latitude, longitude: longitude)
            
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    self.alertError("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                if placemarks!.count > 0 {
                    let pm = placemarks![0]
                    
                    let country = pm.country
                    let city = pm.locality
                    let state = pm.administrativeArea
                    
                    if (!cities.contains(city!)) {
                        cities.append(city!)
                        let cityEntity = CityEntity(city: city!, state: state!, context: (self.coreDataStack?.context)!)
                        self.userInfo.addToUserInfoToCity(cityEntity)
                        cityEntity.addToCityToImage(image)
                    } else {
                        let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
                        let predicateCity = NSPredicate(format: "city == %@", city!)
                        let predicateState = NSPredicate(format: "state == %@", state!)
                        let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicateCity,predicateState])
                        
                        request.predicate = predicateCompound
                        let cityEntity = try? self.coreDataStack?.context.fetch(request)
                        cityEntity??.first?.addToCityToImage(image)
                    }
                    
                    if (!countries.contains(country!)) {
                        countries.append(country!)
                        let countryEntity = CountryEntity(country: country!, context: (self.coreDataStack?.context)!)
                        self.userInfo.addToUserInfoToCountry(countryEntity)
                        countryEntity.addToCountryToImage(image)
                    } else {
                        let request: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
                        request.predicate = NSPredicate(format: "country == %@", country!)
                        let countryEntity = try? self.coreDataStack?.context.fetch(request)
                        countryEntity??.first?.addToCountryToImage(image)
                    }
                    dispatchGroup.leave()
                }
                else {
                    self.alertError("Fail to perform reverse geo location")
                }
            })
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completionHandlerLocations(cities, countries)
        }
    }
    
    private func alertError(_ alertMessage: String) {
        performUIUpdatesOnMain {
            let alert = UIAlertController(title: "Alert", message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
}
