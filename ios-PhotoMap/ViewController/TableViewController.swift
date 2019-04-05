//
//  TableViewController.swift
//  ios-PhotoMap
//
//  Created by Nicholas Sutanto on 11/9/17.
//  Copyright © 2017 Nicholas Sutanto. All rights reserved.
//

import UIKit
import CoreData

extension TableViewController: UITableViewDataSource {
    
}

extension TableViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch segmentationControl.selectedSegmentIndex
        {
        case 0:
            let countryEntity = fetchedResultsControllerCountry.object(at: indexPath)
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "PictureViewController") as! PictureViewController
            
            vc.selectedCountry = countryEntity
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let cityEntity = fetchedResultsControllerCity.object(at: indexPath)
            let vc = self.storyboard!.instantiateViewController(withIdentifier: "PictureViewController") as! PictureViewController
            
            vc.selectedCity = cityEntity
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell", for: indexPath)
        
        switch segmentationControl.selectedSegmentIndex
        {
        case 0:
            let countryEntity = fetchedResultsControllerCountry.object(at: indexPath)
            
            // Configure Cell
            performUIUpdatesOnMain {
                cell.textLabel?.text = countryEntity.country
            }
            
        case 1:
            
            let cityEntity = fetchedResultsControllerCity.object(at: indexPath)
            
            // Configure Cell
            performUIUpdatesOnMain {
                cell.textLabel?.text = cityEntity.city! + ", " + cityEntity.state!
            }
        default:
            break
        }
        
        //Populate the cell from the object
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch segmentationControl.selectedSegmentIndex
        {
        case 0:
            let sections = fetchedResultsControllerCountry.sections
            if sections != nil {
                let sectionInfo = sections![section]
                if (sectionInfo.numberOfObjects > 0) {
                    self.indicator.stopAnimating()
                }
                return sectionInfo.numberOfObjects
            }
            
            return 0
        case 1:
            let sections = fetchedResultsControllerCity.sections
            if sections != nil {
                let sectionInfo = sections![section]
                if (sectionInfo.numberOfObjects > 0) {
                    self.indicator.stopAnimating()
                }
                return sectionInfo.numberOfObjects
            }
            return 0
        default:
            break
        }
        return 0
    }
}

extension TableViewController : ImageLocationUtilDelegate {
    func didFetchImage() {
        performUIUpdatesOnMain {
            self.indicator.stopAnimating()
            self.loadTable()
            self.tableView.reloadData()
        }
    }
}

class TableViewController: UIViewController {

    var indicator = UIActivityIndicatorView()
    @IBOutlet weak var segmentationControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    // Selected Location from previous navigation controller
    var coreDataStack: CoreDataStack?
    
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
    
    func performFetchCity() {
        do {
            try fetchedResultsControllerCity.performFetch()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }
    
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
        
        setActivityIndicator()
        indicator.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        performUIUpdatesOnMain {
            self.loadTable()
            self.tableView.reloadData()
        }
    }
    
    func loadTable() {
        
        switch segmentationControl.selectedSegmentIndex
        {
        case 0:
            performFetchCountry()
        case 1:
            performFetchCity()
        default:
            break
        }
    }
    
    private func setActivityIndicator() {
        indicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        indicator.style = UIActivityIndicatorView.Style.gray
        indicator.center = self.view.center
        self.view.addSubview(indicator)
    }
    
    @IBAction func onSegControlValueChanged(_ sender: Any) {
        performUIUpdatesOnMain {
            self.loadTable()
            self.tableView.reloadData()
        }
        
    }
}
