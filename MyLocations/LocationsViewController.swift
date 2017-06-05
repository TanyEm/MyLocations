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
    var locations = [Location]()
    
    
    // You’re going to ask the managed object context for a list of all Location objects in the data store, sorted by date.
    override func viewDidLoad() {
        super.viewDidLoad()
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
        do { // Now that you have the fetch request, you can tell the context to execute it.
            // The fetch() method returns an array with the sorted objects, or throws an error 
            // in case something went wrong. That’s why this happens inside a do-try-catch block.
            locations = try managedObjectContext.fetch(fetchRequest)
        } catch {
            fatalCoreDataError(error)
        }
    }
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        
        let location = locations[indexPath.row]
        
        
        let descriptionLabel = cell.viewWithTag(100) as! UILabel
        descriptionLabel.text = location.locationDescription
        
        let addressLabel = cell.viewWithTag(101) as! UILabel
        if let placemark = location.placemark {
            var text = ""
            if let s = placemark.subThoroughfare {
                text += s + " "
            }
            
            if let s = placemark.thoroughfare {
                text += s + ", "
            }
            
            if let s = placemark.locality {
                text += s
            }
            addressLabel.text = text
        } else {
            addressLabel.text = ""
        }
        
        return cell
    }
}
