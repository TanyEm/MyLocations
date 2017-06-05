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
    
    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        
        let descriptionLabel = cell.viewWithTag(100) as! UILabel
        descriptionLabel.text = "If you can see this"
        
        let addressLabel = cell.viewWithTag(101) as! UILabel
        addressLabel.text = "Then it works!"
        
        return cell
    }
}
