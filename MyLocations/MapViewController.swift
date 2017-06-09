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
        // This calls region(for) to calculate a reasonable region that fits all 
        // the Location objects and then sets that region on the map view.
        let theRegion = region(for: locations)
        mapView.setRegion(theRegion, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // This fetches the Location objects and shows them on the map when the view loads.
        updateLocations()
        
        if !locations.isEmpty {
            showLocations()
        }
    }
    
    func updateLocations() {
        mapView.removeAnnotations(locations)
        let entity = Location.entity()
        
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity
        
        locations = try! managedObjectContext.fetch(fetchRequest)
        mapView.addAnnotations(locations)
    }
    
    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion
        
        switch annotations.count {
        case 0:
            // There are no annotations. You’ll center the map on the user’s current position.
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
            
        case 1:
            // There is only one annotation. You’ll center the map on that one annotation.
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 1000, 1000)
            
        default:
            // There are two or more annotations. You’ll calculate the extent of their reach and add a little padding.
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            
            for annotation in annotations {
                // The max() function looks at two values and returns the larger of the two;
                topLeftCoord.latitude = max(topLeftCoord.latitude, annotation.coordinate.latitude)
                // The min() function looks at two values and returns the smaller;
                topLeftCoord.longitude = min(topLeftCoord.longitude, annotation.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, annotation.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, annotation.coordinate.longitude)
            }
            
            let center = CLLocationCoordinate2D(
                latitude: topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) / 2,
                longitude: topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            
            let extraSpace = 1.1
            
            let span = MKCoordinateSpan(
                // The abs() always makes a number positive (absolute value).
                latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace,
                longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
            region = MKCoordinateRegion(center: center, span: span)
        }
        return mapView.regionThatFits(region)
    }
}

extension MapViewController: MKMapViewDelegate {
    
}
