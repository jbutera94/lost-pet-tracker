//
//  SightingsMapViewController.swift
//  Lost Pet Tracker
//
//  Created by Justin Butera on 5/11/17.
//  Copyright © 2017 Justin Butera. All rights reserved.
//

import UIKit
import GoogleMaps
import ObjectiveC
import Firebase
import FirebaseDatabase

// Add petID property to all GMSMarkers

// petID is a custom property and allows markers to
// send the ID of the sighting to the details view
// when the marker is tapped.
extension GMSMarker {
    private struct markerCustomProperties {
        static var petID:String? = nil
    }
    var petID:String? {
        get {
            return objc_getAssociatedObject(self, &markerCustomProperties.petID) as? String
        }
        
        set {
            if let unwrappedValue = newValue {
                objc_setAssociatedObject(self, &markerCustomProperties.petID, unwrappedValue as NSString?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
}

class SightingsMapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    // Set up Google Maps Location
    var locationManager = CLLocationManager()
    let mapView = GMSMapView()
    var currentLocation: CLLocation? = nil
    let myGMSGeocoder: GMSGeocoder = GMSGeocoder()
    
    // Set up Firebase
    var dbRef: DatabaseReference!
    
    // Initialize pet sightings list
    var petSightings: [PetSighting] = []
    
    // Gets street name from location coordinate
    func getStreetName(position: CLLocationCoordinate2D) -> String {
        var finalStreetName = ""
        // Runs getStreetNameCalculation, which returns street name in callback
        getStreetNameCalculation(position: position, callback: {(streetName: String) -> () in finalStreetName = streetName })
        print(finalStreetName)
        return ""
    }
    
    // Returns street name from location coordinate into callback
    func getStreetNameCalculation(position: CLLocationCoordinate2D, callback: @escaping (String) -> ()) -> Void {
        var streetName: String = ""
        myGMSGeocoder.reverseGeocodeCoordinate(position) { response, error -> Void in
            if let location = response?.firstResult() {
                streetName = location.thoroughfare!
                callback(streetName)
            }
        }
    }
    
    // Display sighting markers on map
    func displayMarkers(mapView: GMSMapView) -> () {
        for sighting in self.petSightings {
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: sighting.latitude, longitude: sighting.longitude)
            marker.title = sighting.petType
            marker.snippet = sighting.generateSpottedTime()
            marker.map = mapView
            marker.petID = sighting.petID
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        // Loads mapView
        view = mapView
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        // Starts recording location
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // 
        dbRef = Database.database().reference()
        dbRef.observe(DataEventType.value, with: {(snapshot: DataSnapshot) in
            let dictionary = snapshot.value as? [String : AnyObject] ?? [:]
            self.petSightings = PetSighting.generateSightingList(dictionary: dictionary)
            self.mapView.clear()
            self.displayMarkers(mapView: self.mapView)
            
        })
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("marker id \(String(describing: marker.petID))")

        self.performSegue(withIdentifier: "MapToDetailsSegue", sender: PetSighting.findPetSighting(petID: marker.petID!, petSightings: self.petSightings))
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MapToDetailsSegue" {
            if let destinationController = segue.destination as? SightingDetailsViewController {
                destinationController.sighting = sender as? PetSighting
            }
        }
    }
    
    // CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        currentLocation = location
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 14)
        mapView.animate(to: camera)
        self.locationManager.stopUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
