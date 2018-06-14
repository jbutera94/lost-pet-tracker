//
//  SightingDetailsViewController.swift
//  Lost Pet Tracker
//
//  Created by Justin Butera on 5/11/17.
//  Copyright © 2017 Justin Butera. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseDatabase
import Firebase
import Cloudinary

class SightingDetailsViewController: UIViewController, CLLocationManagerDelegate {

    // Location setup
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation? = nil
    
    // Outlets
    @IBOutlet weak var directionsBtn: UIButton!
    @IBOutlet weak var photoOfPetLabel: UILabel!
    @IBOutlet weak var petImage: UIImageView!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var progressIndicator: UIActivityIndicatorView!
    
    // Current sighting and ID
    var sighting: PetSighting? = nil
    var sightingID: Int? = nil
    
    // Cloudinary
    let cldConfig = CLDConfiguration(cloudinaryUrl: "cloudinary://238511635694454:zISbNSrcKI1TUHAKEEAaU-L0DXc@jbutera94")
    var cloudinary: CLDCloudinary!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup cloudinary
        cloudinary = CLDCloudinary(configuration: cldConfig!)
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)

        // Setup location
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        print("in sighting details, id \(String(describing: sighting?.petID))")
        
        // Set up pet label text to be pet type of sighting
        photoOfPetLabel.text = "Photo of \(sighting?.petType ?? "Pet"):"
        
        petImage.contentMode = .scaleAspectFit
        progressIndicator.hidesWhenStopped = true
        
        // Generate URL of image in cloudinary
        let url = URL(string: cloudinary.createUrl().generate((sighting?.imageURL!)!)!)
        print(url ?? "")
        
        progressIndicator.startAnimating()
        
        // Download image and set to image view
        petImage.sd_setImage(with: url, placeholderImage: nil, options: [],completed: { (image, error, cacheType, imageURL) in
            print("Loaded image")
            self.progressIndicator.stopAnimating()
        })
        
        // Set spotted time
        timestampLabel.text = sighting?.generateSpottedTime()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        // Rounded corners to direction button
        directionsBtn.layer.cornerRadius = 0.05 * directionsBtn.bounds.width
        directionsBtn.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // If Google Maps Directions button is tapped
    @IBAction func directionButton(_ sender: UIButton) {
        // Check if Google Maps is installed
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            self.locationManager.stopUpdatingLocation()
            // Ensure lat and long are defined
            guard let sightingLatitude = sighting?.latitude else {
                fatalError("Missing latitude")
            }
            guard let sightingLongitude = sighting?.longitude else {
                fatalError("Missing longitude")
            }
            if let currentLat = currentLocation?.coordinate.latitude, let currentLong = currentLocation?.coordinate.longitude {
                // Send user to Google Maps with lat and long to sighting
                UIApplication.shared.openURL(URL(string: "comgooglemaps://?saddr=\(String(describing: currentLat)),\(String(describing: currentLong))&daddr=\(sightingLatitude),\(sightingLongitude)&directionsmode=driving")!)
            } else {
                // If no location available, error using dialog box
                let alert = UIAlertController(title: "No location available", message: "No location is available, please try again later.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Ok", style: .default, handler: {(action) -> Void in })
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
            }
            
        } else { // If Google Maps not installed, error using dialog box
            let alert = UIAlertController(title: "Directions not available", message: "Please install Google Maps to get directions to pet sighting", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: {(action) -> Void in})
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        // If location changes, set new distance to sighting and spotted time
        guard let distance = currentLocation?.distance(from: CLLocation(latitude: (sighting?.latitude)!, longitude: (sighting?.longitude)!)) else {
            fatalError("Invalid distance")
        }
        distanceLabel.text = "\(String(round(distance * 0.000621371 * 10)/10)) miles away"
        timestampLabel.text = sighting?.generateSpottedTime()
    }

}
