//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Tanya Tomchuk on 05.06.17.
//  Copyright © 2017 Tanya Tomchuk. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreLocation

class LocationsViewController: UITableViewController {
    var managedObjectContext: NSManagedObjectContext!
    
    // You’re going to ask the managed object context for a list of all Location objects in the data store, sorted by date.
    lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
        
        // The NSFetchRequest is the object that describes which objects you’re going
        // to fetch from the data store. To retrieve an object that you previously saved
        // to the data store, you create a fetch request that describes the search parameters
        // of the object – or multiple objects – that you’re looking for.
        let fetchRequest = NSFetchRequest<Location>()
        
        // Here you tell the fetch request you’re looking for Location entities.
        let entity = Location.entity()
        fetchRequest.entity = entity

        // The NSSortDescriptor tells the fetch request to sort on the date attribute,
        // in ascending order. In order words, the Location objects that the user added
        // first will be at the top of the list.
        // There is you said “Get all Location objects from the data store and sort them by date.”
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchBatchSize = 20
        
        // If any Location objects change after that initial fetch, the 
        // NSFetchedResultsController’s delegate methods are called 
        // to let you know about these changes.
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: nil,
            cacheName: "Locations")
        fetchedResultsController.delegate = self
            
        return fetchedResultsController
    }()
    
    // The deinit method is invoked when this view controller is destroyed.
    deinit {
        fetchedResultsController.delegate = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        performFetch()
        // An Edit button in the navigation bar that triggers a mode that lets you delete rows.
        navigationItem.rightBarButtonItem = editButtonItem
    }
    
    // This method is invoked when the user taps a row in the Locations screen. 
    // It figures out which Location object belongs to the row and puts it in 
    // the new locationToEdit property of LocationDetailsViewController.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                let location = fetchedResultsController.object(at: indexPath)
                controller.locationToEdit = location
            }
        }
    }
    
    func performFetch() {
        do {
            // Now that you have the fetch request, you can tell the context to execute it.
            // The fetch() method returns an array with the sorted objects, or throws an error
            // in case something went wrong. That’s why this happens inside a do-try-catch block.
            try fetchedResultsController.performFetch()
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // The fetched results controller’s sections property returns an array of
        // NSFetchedResultsSectionInfo objects that describe each section of the table view.
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! LocationCell
        
        let location = fetchedResultsController.object(at: indexPath)
        cell.configure(for: location)
        return cell
    }
    
    // This method gets the Location object from the selected row and then tells the context to delete that object. 
    // This will trigger the NSFetchedResultsController to send a notification to the delegate 
    // (NSFetchedResultsChangeDelete), which then removes the corresponding row from the table.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete {
            let location = fetchedResultsController.object(at: indexPath)
            managedObjectContext.delete(location)
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
}

extension LocationsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            print("*** controllerWillChangeContent")
            tableView.beginUpdates()
        }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any, at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            switch type {
            case .insert:
                print("*** NSFetchedResultsChangeInsert (object)")
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                print("*** NSFetchedResultsChangeDelete (object)")
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                print("*** NSFetchedResultsChangeUpdate (object)")
                if let cell = tableView.cellForRow(at: indexPath!) as? LocationCell {
                    let location = controller.object(at: indexPath!) as! Location
                    cell.configure(for: location)
                }
            case .move:
                print("*** NSFetchedResultsChangeMove (object)")
                tableView.deleteRows(at: [indexPath!], with: .fade)
                tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType){
            switch type {
                case .insert:
                    print("*** NSFetchedResultsChangeInsert (section)")
                    tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
                case .delete:
                    print("*** NSFetchedResultsChangeDelete (section)")
                    tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
                case .update:
                    print("*** NSFetchedResultsChangeUpdate (section)")
                case .move:
                    print("*** NSFetchedResultsChangeMove (section)")
            }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}
