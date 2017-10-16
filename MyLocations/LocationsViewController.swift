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
        let sortDescriptor1 = NSSortDescriptor(key: "date", ascending: true)
        
        let sortDescriptor2 = NSSortDescriptor(key: "category", ascending: true)
        //First this sorts the Location objects by category and inside each of these groups it sorts by date.
        fetchRequest.sortDescriptors = [sortDescriptor2, sortDescriptor1]
        fetchRequest.fetchBatchSize = 20
        
        // If any Location objects change after that initial fetch, the 
        // NSFetchedResultsController’s delegate methods are called 
        // to let you know about these changes.
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: self.managedObjectContext,
            sectionNameKeyPath: "category",
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
        // This makes the table view itself black but does not alter the cells.
        // The awakeFromNib() method in LocationCell.swift to change the appearance of the actual cells
        tableView.backgroundColor = UIColor.black
        tableView.separatorColor = UIColor(white: 1.0, alpha: 0.2)
        tableView.indicatorStyle = .white
        
        tableView.sectionHeaderHeight = 28

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
    
    // Requested the fetcher object for a list of the sections, which is an array of NSFetchedResultsSectionInfo objects
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    // and then looked inside that array to find out how many sections there are and what their names are.
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.name.uppercased()
    }
    
    // This method gets the Location object from the selected row and then tells the context to delete that object. 
    // This will trigger the NSFetchedResultsController to send a notification to the delegate 
    // (NSFetchedResultsChangeDelete), which then removes the corresponding row from the table.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete {
            let location = fetchedResultsController.object(at: indexPath)
            location.removePhotoFile()
            managedObjectContext.delete(location)
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalCoreDataError(error)
            }
        }
    }
    
    // MARK: - UITableViewDelegate
    // This is a UITableView delegate method. It gets called once for each section in the table view.
    // Here you create a label for the section name, a 1-pixel high view that functions as a separator
    // line, and a container view to hold these two subviews.
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let labelRect = CGRect(x: 15,
                               y: tableView.sectionHeaderHeight - 14,
                               width: 300,
                               height: 14)
        let label = UILabel(frame: labelRect)
        label.font = UIFont.boldSystemFont(ofSize: 11)
        label.text = tableView.dataSource!.tableView!(tableView, titleForHeaderInSection: section)
        label.textColor = UIColor(white: 1.0, alpha: 0.4)
        label.backgroundColor = UIColor.clear
        let separatorRect = CGRect(x: 15,
                                   y: tableView.sectionHeaderHeight - 0.5,
                                   width: tableView.bounds.size.width - 15,
                                   height: 0.5)
        let separator = UIView(frame: separatorRect)
        separator.backgroundColor = tableView.separatorColor
        let viewRect = CGRect(x: 0,
                              y: 0,
                              width: tableView.bounds.size.width,
                              height: tableView.sectionHeaderHeight)
        let view = UIView(frame: viewRect)
        view.backgroundColor = UIColor(white: 0, alpha: 0.85)
        view.addSubview(label)
        view.addSubview(separator)
        return view
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
