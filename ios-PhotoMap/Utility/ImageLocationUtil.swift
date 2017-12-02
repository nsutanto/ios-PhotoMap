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

protocol ImageLocationUtilDelegate: class {
    func didFetchImage()
}

class ImageLocationUtil {

    // Initialize core data stack
    let coreDataStack: CoreDataStack?
    weak var imageLocationDelegate : ImageLocationUtilDelegate?
    
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
                        
                        // tell the subscriber that we are done
                        self.imageLocationDelegate?.didFetchImage()
                        
                        completionHandlerUserImages(images, nil)
                    }
                    else {
                        print("******* HAS ERROR")
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
    
    func getCountryEntity(_ countryString: String, completionHandlerLocations: @escaping(_ countryEntity: CountryEntity?) -> Void) {
        
        self.coreDataStack?.context.perform {
            let request: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
            request.predicate = NSPredicate(format: "country == %@", countryString)
            if let countryEntityResult = try? self.coreDataStack?.context.fetch(request) {
                let countryEntity = countryEntityResult?.first
                completionHandlerLocations(countryEntity)
            }
            else {
                completionHandlerLocations(nil)
            }
        }
    }
    
    func getCityEntity(_ cityString: String, _ stateString: String, completionHandlerLocations: @escaping(_ cityEntity: CityEntity?) -> Void) {
        
        self.coreDataStack?.context.perform {
            let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
            let predicateCity = NSPredicate(format: "city == %@", cityString)
            let predicateState = NSPredicate(format: "state == %@", stateString)
            let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicateCity,predicateState])
            
            request.predicate = predicateCompound
            if let cityEntityResult = try? self.coreDataStack?.context.fetch(request) {
                let cityEntity = cityEntityResult?.first
                completionHandlerLocations(cityEntity)
            }
            else {
                completionHandlerLocations(nil)
            }
        }
    }
    
    private func getImageLocation(_ userInfo: UserInfo, _ images: [Image], completionHandlerImageLocation: @escaping (_ error: NSError?) -> Void ) {
        
        self.performReverseGeoLocation(userInfo, images, completionHandlerLocations: { (cities, countries, error) in
            self.coreDataStack?.save()
        
            DispatchQueue.main.async {
                self.performReverseGeoLocationGoogle(userInfo, images, completionHandlerLocations: { (cities, countries, error) in
                    self.coreDataStack?.save()
                    completionHandlerImageLocation(error)
                })
            }
        })
    }
    
    private func performReverseGeoLocation(_ userInfo: UserInfo, _ images: [Image], completionHandlerLocations: @escaping(_ cities: [String]?, _ countries: [String]?, _ error: NSError?) -> Void) {
        // https://stackoverflow.com/questions/47129345/swift-how-to-perform-task-completion/47130196#47130196
        let dispatchGroup = DispatchGroup()
        
        // init city and country from core data
        getSavedData { (savedImages, savedCities, savedCountries) in
            var cities = savedCities
            var countries = savedCountries
            savedImages?.forEach { (image) in
                if (image.imageToCity == nil || image.imageToCountry == nil) {
                    dispatchGroup.enter()
                   
                    let longitude = image.longitude
                    let latitude = image.latitude
                    
                    let location = CLLocation(latitude: latitude, longitude: longitude)
                    
                    CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                        if error != nil {
                            dispatchGroup.leave()
                        }
                        else {
                            let pm = placemarks![0]
                            
                            let country = pm.country
                            let city = pm.locality
                            let state = pm.administrativeArea
                            
                            if city != nil && state != nil {
                                let citySearch = city!+state!
                                if (!(cities?.contains(citySearch))!) {
                                    cities?.append(citySearch)
                                    self.coreDataStack?.context.perform {
                                        let cityEntity = CityEntity(city: city!, state: state!, context: (self.coreDataStack?.context)!)
                                        userInfo.addToUserInfoToCity(cityEntity)
                                        cityEntity.addToCityToImage(image)
                                        image.imageToCity = cityEntity
                                    }
                                } else {
                                    let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
                                    let predicateCity = NSPredicate(format: "city == %@", city!)
                                    let predicateState = NSPredicate(format: "state == %@", state!)
                                    let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicateCity,predicateState])
                                    
                                    request.predicate = predicateCompound
                                    let cityEntity = try? self.coreDataStack?.context.fetch(request)
                                    self.coreDataStack?.context.perform {
                                        cityEntity??.first?.addToCityToImage(image)
                                        image.imageToCity = cityEntity??.first
                                    }
                                }
                            }
                            
                            if country != nil {
                               
                                if (!(countries?.contains(country!))!) {
                                    countries?.append(country!)
                                    self.coreDataStack?.context.perform {
                                        let countryEntity = CountryEntity(country: country!, context: (self.coreDataStack?.context)!)
                                        userInfo.addToUserInfoToCountry(countryEntity)
                                        countryEntity.addToCountryToImage(image)
                                        image.imageToCountry = countryEntity
                                    }
                                } else {
                                    let request: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
                                    request.predicate = NSPredicate(format: "country == %@", country!)
                                    self.coreDataStack?.context.perform {
                                        let countryEntity = try? self.coreDataStack?.context.fetch(request)
                                        countryEntity??.first?.addToCountryToImage(image)
                                        image.imageToCountry = countryEntity??.first
                                    }
                                }
                            }
                            dispatchGroup.leave()
                        }
                    })
                }
            }
        
            dispatchGroup.notify(queue: DispatchQueue.main) {
                completionHandlerLocations(cities, countries, nil)
            }
        }
    }
    
    private func performReverseGeoLocationGoogle(_ userInfo: UserInfo, _ images: [Image], completionHandlerLocations: @escaping(_ cities: [String]?, _ countries: [String]?, _ error: NSError?) -> Void) {
        // https://stackoverflow.com/questions/47129345/swift-how-to-perform-task-completion/47130196#47130196
        let dispatchGroup = DispatchGroup()
        
        // init city and country from core data
        //var cities = initCities()
        //var countries = initCountries()
        //let imagesLocal = getImagesFromCoreData()
        
        getSavedData { (savedImages, savedCities, savedCountries) in
            var cities = savedCities
            var countries = savedCountries
            savedImages?.forEach { (image) in
                if (image.imageToCity == nil || image.imageToCountry == nil) {
                    dispatchGroup.enter()
                    
                    let longitude = image.longitude
                    let latitude = image.latitude
                    
                    GoogleClient.sharedInstance().performReverseGeoLocation(latitude, longitude) { (country, state, city, error) in
                        if error != nil {
                            dispatchGroup.leave()
                        }
                        else {
                            if city != nil && state != nil {
                                let citySearch = city!+state!
                                
                                if (!((cities?.contains(citySearch))!)) {
                                    cities?.append(citySearch)
                                    self.coreDataStack?.context.perform {
                                        let cityEntity = CityEntity(city: city!, state: state!, context: (self.coreDataStack?.context)!)
                                        userInfo.addToUserInfoToCity(cityEntity)
                                        cityEntity.addToCityToImage(image)
                                        image.imageToCity = cityEntity
                                    }
                                } else {
                                    let request: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
                                    let predicateCity = NSPredicate(format: "city == %@", city!)
                                    let predicateState = NSPredicate(format: "state == %@", state!)
                                    let predicateCompound = NSCompoundPredicate.init(type: .and, subpredicates: [predicateCity,predicateState])
                                    
                                    request.predicate = predicateCompound
                                    self.coreDataStack?.context.perform {
                                        let cityEntity = try? self.coreDataStack?.context.fetch(request)
                                        cityEntity??.first?.addToCityToImage(image)
                                        image.imageToCity = cityEntity??.first
                                    }
                                }
                            }
                            
                            if country != nil {
                                if (!(countries?.contains(country!))!) {
                                    countries?.append(country!)
                                    self.coreDataStack?.context.perform {
                                        let countryEntity = CountryEntity(country: country!, context: (self.coreDataStack?.context)!)
                                        userInfo.addToUserInfoToCountry(countryEntity)
                                        countryEntity.addToCountryToImage(image)
                                        image.imageToCountry = countryEntity
                                    }
                                } else {
                                    let request: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
                                    request.predicate = NSPredicate(format: "country == %@", country!)
                                    self.coreDataStack?.context.perform {
                                        let countryEntity = try? self.coreDataStack?.context.fetch(request)
                                        countryEntity??.first?.addToCountryToImage(image)
                                        image.imageToCountry = countryEntity??.first
                                    }
                                }
                            }
                            dispatchGroup.leave()
                        }
                    }
                }
            }
            
            dispatchGroup.notify(queue: DispatchQueue.main) {
                completionHandlerLocations(cities, countries, nil)
            }
        }
        
        
    }

    private func getSavedData(completionHandlerSavedData: @escaping (_ images: [Image]?, _ cities: [String]?,  _ countries: [String]?) -> Void) {
        let requestImage: NSFetchRequest<Image> = Image.fetchRequest()
        let requestCity: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        let requestCountry: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
        self.coreDataStack?.context.perform {
            // Get images
            let images = try? self.coreDataStack?.context.fetch(requestImage)
            
            // Get cities string
            var cities = [String]()
            let citiEntities = try? self.coreDataStack?.context.fetch(requestCity)
            if (citiEntities != nil) {
                for cityEntity in citiEntities!! {
                    if let cityStr = cityEntity.city {
                        if let stateStr = cityEntity.state {
                            cities.append(cityStr+stateStr)
                        }
                    }
                }
            }
            
            // Get country string
            var countries = [String]()
            let countryEntities = try? self.coreDataStack?.context.fetch(requestCountry)
            for countryEntity in countryEntities!! {
                if let countryStr = countryEntity.country {
                    countries.append(countryStr)
                }
            }
            
            completionHandlerSavedData(images!, cities, countries)
        }
    }
    
    private func cleanUpEmptyCityAndCountry() {
        
        let requestCity: NSFetchRequest<CityEntity> = CityEntity.fetchRequest()
        
        if let cities = try? coreDataStack?.context.fetch(requestCity) {
            for cityEntity in cities! {
                self.coreDataStack?.context.perform {
                    if cityEntity.cityToImage?.count == 0 {
                        self.coreDataStack?.context.delete(cityEntity)
                        self.coreDataStack?.save()
                    }
                }
            }
        }
        
        let requestCountry: NSFetchRequest<CountryEntity> = CountryEntity.fetchRequest()
        
        if let countries = try? coreDataStack?.context.fetch(requestCountry) {
            for countryEntity in countries! {
                
                if countryEntity.countryToImage?.count == 0 {
                    self.coreDataStack?.context.perform {
                        self.coreDataStack?.context.delete(countryEntity)
                        self.coreDataStack?.save()
                    }
                }
            }
        }
    }
}
