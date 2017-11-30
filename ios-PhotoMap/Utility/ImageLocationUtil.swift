//
//  ImageLocationUtil.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 11/21/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class ImageLocationUtil {

    // Initialize core data stack
    let coreDataStack: CoreDataStack?
    
    class func sharedInstance() -> ImageLocationUtil {
        struct Singleton {
            static var sharedInstance = ImageLocationUtil()
        }
        return Singleton.sharedInstance
    }
    
    init() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        coreDataStack = delegate.stack
    }
    
    func getUserImages(_ userInfo: UserInfo, completionHandlerUserImages: @escaping (_ images : [Image]?, _ error: NSError?) -> Void ) {
        InstagramClient.sharedInstance().getAllImages(nil, completionHandlerGetImages: { (images, error) in
            if (error == nil) {
                self.getImageLocation(userInfo, images!, completionHandlerImageLocation: { (error) in
                    if (error == nil) {
                        // check for empty relation
                        self.cleanUpEmptyCityAndCountry()
                        
                        completionHandlerUserImages(images, nil)
                    }
                    else {
                        completionHandlerUserImages(nil, error)
                    }
                })
            }
            else {
                let errorInfo = [NSLocalizedDescriptionKey : "Fail to get user images"]
                completionHandlerUserImages(nil, NSError(domain: "getUserImages", code: 1, userInfo: errorInfo))
            }
        })
    }
    
    private func getImageLocation(_ userInfo: UserInfo, _ images: [Image], completionHandlerImageLocation: @escaping (_ error: NSError?) -> Void ) {
        performReverseGeoLocation(userInfo, images, completionHandlerLocations: { (cities, countries, error) in
            self.coreDataStack?.save()
            completionHandlerImageLocation(error)
        })
    }
    
    private func performReverseGeoLocation(_ userInfo: UserInfo, _ images: [Image], completionHandlerLocations: @escaping(_ cities: [String]?, _ countries: [String]?, _ error: NSError?) -> Void) {
        // https://stackoverflow.com/questions/47129345/swift-how-to-perform-task-completion/47130196#47130196
        let dispatchGroup = DispatchGroup()
        
        // init city and country from core data
        var cities = initCities()
        var countries = initCountries()
        
        images.forEach { (image) in
            if (image.imageToCity == nil || image.imageToCountry == nil) {
                
                dispatchGroup.enter()
                
                let longitude = image.longitude
                let latitude = image.latitude
                
                let location = CLLocation(latitude: latitude, longitude: longitude)
                
                CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                    if error != nil {
                        //let error = "Reverse geocoder failed with error" + (error?.localizedDescription)!
                        //let errorInfo = [NSLocalizedDescriptionKey : error]
                        //completionHandlerLocations(nil, nil, NSError(domain: "performReverseGeoLocation", code: 1, userInfo: errorInfo))
                        //return
                        dispatchGroup.leave()
                    }
                    else {
                        if placemarks!.count > 0 {
                            let pm = placemarks![0]
                            
                            let country = pm.country
                            let city = pm.locality
                            let state = pm.administrativeArea
                            
                            if city != nil && state != nil {
                                let citySearch = city!+state!
                                if (!cities.contains(citySearch)) {
                                    cities.append(citySearch)
                                    let cityEntity = CityEntity(city: city!, state: state!, context: (self.coreDataStack?.context)!)
                                    userInfo.addToUserInfoToCity(cityEntity)
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
                            }
                            
                            if country != nil {
                                if (!countries.contains(country!)) {
                                    countries.append(country!)
                                    let countryEntity = CountryEntity(country: country!, context: (self.coreDataStack?.context)!)
                                    userInfo.addToUserInfoToCountry(countryEntity)
                                    countryEntity.addToCountryToImage(image)
                                } else {
                                    let request: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
                                    request.predicate = NSPredicate(format: "country == %@", country!)
                                    let countryEntity = try? self.coreDataStack?.context.fetch(request)
                                    countryEntity??.first?.addToCountryToImage(image)
                                }
                            }
                            dispatchGroup.leave()
                        }
                    }
                    //else do {
                     //   dispatchGroup.leave()
                        // do nothing
                        //let errorInfo = [NSLocalizedDescriptionKey : "Fail to perform reverse geo location"]
                        //completionHandlerLocations(nil, nil, NSError(domain: "performReverseGeoLocation", code: 1, userInfo: errorInfo))
                    //}
                })
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            completionHandlerLocations(cities, countries, nil)
        }
    }
    
    private func initCities() -> [String] {
        // init city and country from core data
        var cities = [String]()
        let requestCity: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        if let citiEntities = try? coreDataStack?.context.fetch(requestCity) {
            for cityEntity in citiEntities! {
                if let cityStr = cityEntity.city {
                    if let stateStr = cityEntity.state {
                        cities.append(cityStr+stateStr)
                    }
                }
            }
        }
        return cities
    }
    
    private func initCountries() -> [String] {
        var countries = [String]()
        let requestCountry: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
        if let countryEntities = try? coreDataStack?.context.fetch(requestCountry) {
            for countryEntity in countryEntities! {
                if let countryStr = countryEntity.country {
                    countries.append(countryStr)
                }
            }
        }
        return countries
    }
    
    private func cleanUpEmptyCityAndCountry() {
        
        let requestCity: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        
        if let cities = try? coreDataStack?.context.fetch(requestCity) {
            for cityEntity in cities! {
                
                if cityEntity.cityToImage?.count == 0 {
                    coreDataStack?.context.delete(cityEntity)
                    coreDataStack?.save()
                }
            }
        }
        
        let requestCountry: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
        
        if let countries = try? coreDataStack?.context.fetch(requestCountry) {
            for countryEntity in countries! {
                
                if countryEntity.countryToImage?.count == 0 {
                    coreDataStack?.context.delete(countryEntity)
                    coreDataStack?.save()
                }
            }
        }
    }
}
