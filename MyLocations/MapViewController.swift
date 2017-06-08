//
//  MapViewController.swift
//  MyLocations
//
//  Created by Tanya Tomchuk on 08/06/2017.
//  Copyright © 2017 Tanya Tomchuk. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var managedObjectContext: NSManagedObjectContext!
    var locations = [Location]()
    
    // When you press the User button, it zooms in the map to a region
    // that is 1000 by 1000 meters (a little more than half a mile in both 
    // directions) around the user’s position.
    @IBAction func showUser() {
        let region = MKCoordinateRegionMakeWithDistance(
            mapView.userLocation.coordinate, 1000, 1000)
        mapView.setRegion(mapView.regionThatFits(region), animated: true)
    }
    
    @IBAction func showLocations() {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // This fetches the Location objects and shows them on the map when the view loads.
        updateLocations()
    }
    
    func updateLocations() {
        mapView.removeAnnotations(locations)
        let entity = Location.entity()
        
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity
        
        locations = try! managedObjectContext.fetch(fetchRequest)
        mapView.addAnnotations(locations)
    }
}

extension MapViewController: MKMapViewDelegate {
    
}
