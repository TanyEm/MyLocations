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
    
    var managedObjectContext: NSManagedObjectContext!{
        didSet {
            NotificationCenter.default.addObserver(forName:
                Notification.Name.NSManagedObjectContextObjectsDidChange,
                object: managedObjectContext,
                queue: OperationQueue.main) { _ in
                if self.isViewLoaded {
                    self.updateLocations()
                }
            }
        }
    }
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
    
    
    // The method takes one parameter, sender, that refers to the control that sent the action message.
    // In this case the sender will be the (i) button.
    func showLocationDetails(_ sender: UIButton) {
        performSegue(withIdentifier: "EditLocation", sender: sender)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! LocationDetailsViewController
            controller.managedObjectContext = managedObjectContext
            
            let button = sender as! UIButton
            let location = locations[button.tag]
            controller.locationToEdit = location
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Because MKAnnotation is a protocol, there may be other objects apart from the Location object 
        // that wants to be annotations on the map. An example is the blue dot that represents the user’s current location.
        guard annotation is Location else {
            return nil
        }
        // This looks similar to creating a table view cell.You ask the map view to re-use 
        // an annotation view object. If it cannot find a recyclable annotation view, then you create a new one.
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        
        if annotationView == nil {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            // This sets some properties to configure the look and feel of the annotation view. 
            // Previously the pins were red, but you make them green here.
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = false
            pinView.pinTintColor = UIColor(red: 0.32, green: 0.82, blue: 0.4, alpha: 1)
            
            // You create a new UIButton object that looks like a detail disclosure button.
            let rightButton = UIButton(type: .detailDisclosure)
            //  You use the target-action pattern to hook up the button’s “Touch Up Inside” event with a new method showLocationDetails()
            rightButton.addTarget(self, action: #selector(showLocationDetails), for: .touchUpInside)
            // Add the button to the annotation view’s accessory view.
            pinView.rightCalloutAccessoryView = rightButton
            annotationView = pinView
        }
            
        if let annotationView = annotationView {
            annotationView.annotation = annotation
            
            // Once the annotation view is constructed and configured, you obtain a reference to that detail disclosure button
            // again and set its tag to the index of the Location object in the locations array. That way you can find 
            // the Location object later in showLocationDetails() when the button is pressed.
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            
            if let index = locations.index(of: annotation as! Location) {
                button.tag = index
            }
        }
        return annotationView
    }
}
