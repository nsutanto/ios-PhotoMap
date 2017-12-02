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
                return sectionInfo.numberOfObjects
            }
            
            return 0
        case 1:
            let sections = fetchedResultsControllerCity.sections
            if sections != nil {
                let sectionInfo = sections![section]
                return sectionInfo.numberOfObjects
            }
            return 0
        default:
            break
        }
        return 0
    }
}

/*
extension TableViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move:
            break
        case .update:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}
*/

extension TableViewController : ImageLocationUtilDelegate {
    func didFetchImage() {
        performUIUpdatesOnMain {
            self.loadTable()
            self.tableView.reloadData()
        }
    }
}

class TableViewController: UIViewController {

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
        
        // Initialize delegate
        //fetchedResultsControllerCity.delegate = self
        //fetchedResultsControllerCountry.delegate = self
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
    
    @IBAction func onSegControlValueChanged(_ sender: Any) {
        performUIUpdatesOnMain {
            self.loadTable()
            self.tableView.reloadData()
        }
        
    }
}
