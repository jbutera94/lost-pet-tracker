//
//  ReportPetViewController.swift
//  Lost Pet Tracker
//
//  Created by Justin Butera on 5/10/17.
//  Copyright © 2017 Justin Butera. All rights reserved.
//

import UIKit
import MobileCoreServices
import GoogleMaps
import Firebase
import FirebaseDatabase

class ReportPetViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    // Outlets
    @IBOutlet weak var retakePicBtn: UIButton!
    @IBOutlet weak var progress: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var myView: UIView!
    @IBOutlet weak var typeOfPetControl: UISegmentedControl!
    @IBOutlet weak var submitBtn: UIButton!
    
    // Setting up Google Maps Location
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation? = nil
    let dispatchGroup = DispatchGroup()
    
    // Setting up Firebase
    var dbRef: DatabaseReference!
    
    // Using PET_TYPES as array for ID of option tapped in segemented control
    let PET_TYPES = ["Dog", "Cat", "Other"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Asks for authorization to use phone's location
        if CLLocationManager.authorizationStatus() != CLAuthorizationStatus.authorizedWhenInUse {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        // Starts recording location
        self.locationManager.startUpdatingLocation()
        self.locationManager.delegate = self
        
        // Progress circle disappears when not spinning
        self.progress.hidesWhenStopped = true
        
        // Ask user to take photo
        showPhotoActionSheet()
    }
    
    override func viewDidLayoutSubviews() {
        // Add rounded corners to "Retake Picture" button
        retakePicBtn.layer.cornerRadius = 0.05 * retakePicBtn.bounds.width
        retakePicBtn.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // When "Retake Picture" is tapped, show photo action sheet again
    @IBAction func reactivateActionSheet(_ sender: UIButton) {
        showPhotoActionSheet()
    }
    
    @IBAction func submitBtn(_ sender: UIButton) {
        // Stop recording location
        self.locationManager.stopUpdatingLocation()
        
        // Add new sighting to Firebase if image is taken
        
        // New sighting has no petID or imageURL because neither have been generated yet.
        
        // PetSighting.addPetSighting will populate those properties after they are
        // generated (when sighting is given a random ID in Firebase and image is
        // given a random URL in Cloudinary).
        dbRef = Database.database().reference()
        if let image = imageView.image {
            let sighting = PetSighting(petID: "-1", petType: PET_TYPES[typeOfPetControl.selectedSegmentIndex], timestampNumber: Date.init().timeIntervalSinceReferenceDate, image: image, latitude: (self.currentLocation?.coordinate.latitude)!, longitude: (self.currentLocation?.coordinate.longitude)!, imageURL: nil)
            self.progress.startAnimating()
            self.submitBtn.isEnabled = false
            PetSighting.addPetSighting(sighting: sighting, completed: {() in
                self.progress.stopAnimating()
                self.submitBtn.isEnabled = true
                // Change view to Thank You view controller
                self.performSegue(withIdentifier: "ThankYouSegue", sender: nil)
            })
            print("lat: \(self.currentLocation?.coordinate.latitude ?? -1), long: \(self.currentLocation?.coordinate.longitude ?? -1)")

        } else { // If no image is taken, display alert telling user to take a picture
            let alert = UIAlertController(title: "No picture found", message: "Please tap \"Re-take photo\" to take the photo of the lost pet", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: {(action) -> Void in
                // Nothing in callback dismisses action sheet
            })
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    // Updates location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        currentLocation = location
    }
    
    // If user chooses to use camera, show camera so they can take a picture
    private func useCamera() {
        // Only works if camera is available
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // If user chooses to use photo library, show photo library so they can choose a picture
    private func usePhotoLibrary() {
        // Only works if photo library is available
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum) {
            let imagePicker = UIImagePickerController()
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    // After user chooses an image, set image to imageView to show on screen
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! NSString
        
        self.dismiss(animated: true, completion: nil)
        
        if mediaType.isEqual(to: kUTTypeImage as String) {
            imageView.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
    }
    
    // When called, shows photo action sheet with different actions for user to tap on
    private func showPhotoActionSheet() {
        // Action Sheet Controller
        let actionSheetController: UIAlertController = UIAlertController(title: "Take a picture", message: "Please choose an option:", preferredStyle: .actionSheet)
        
        // Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in
            // Nothing in callback dismisses action sheet
        }
        
        // Photo library action
        let photoLibraryAction: UIAlertAction = UIAlertAction(title: "Choose from Photo Library...", style: .default) { action -> Void in
            self.usePhotoLibrary()
        }
        
        // Camera action
        let cameraAction: UIAlertAction = UIAlertAction(title: "Take a picture...", style: .default) { action -> Void in
            self.useCamera()
        }
        
        // Add actions to controller
        actionSheetController.addAction(cameraAction)
        actionSheetController.addAction(photoLibraryAction)
        actionSheetController.addAction(cancelAction)
        
        // Show action sheet controller
        self.present(actionSheetController, animated: true, completion: nil)
    }

}
