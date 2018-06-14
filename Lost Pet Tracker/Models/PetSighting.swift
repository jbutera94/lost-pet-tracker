//
//  PetSighting.swift
//  Lost Pet Tracker
//
//  Created by Justin Butera on 5/14/17.
//  Copyright © 2017 Justin Butera. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import FirebaseDatabase
import Cloudinary

class PetSighting {
    
    // Firebase setup
    static var dbRef: DatabaseReference! = Database.database().reference()
    
    // MARK: Properties
    var petID: String
    var petType: String
    var timestamp: Date
    var image: UIImage
    var latitude: Double
    var longitude: Double
    var imageURL: String?
    
    // Initializer for pet sighting
    init(petID: String?, petType: String, timestampNumber: Double, image: UIImage?, latitude: Double, longitude: Double, imageURL: String?) {
        self.petID = petID ?? "-1"
        self.petType = petType
        self.timestamp = Date.init(timeIntervalSinceReferenceDate: timestampNumber)
        self.image = image ?? UIImage(named: "Unknown Image Icon")!
        self.latitude = latitude
        self.longitude = longitude
        self.imageURL = imageURL
    }
    
    // Returns location coordinate based on lat and long
    func generateLocation() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    // Return pet sighting object given ID and pet sighting list
    static func findPetSighting(petID: String, petSightings: [PetSighting]) -> PetSighting? {
        for sighting in petSightings {
            if sighting.petID == petID {
                return sighting
            }
        }
        return nil
    }
    
    // Adds pet sighting given information about sighting
    static func addPetSighting(sighting: PetSighting, completed: @escaping () -> ()) -> Void {
        
        // Sets up cloudinary
        let cldConfig = CLDConfiguration(cloudinaryUrl: "cloudinary://238511635694454:zISbNSrcKI1TUHAKEEAaU-L0DXc@jbutera94")
        let cloudinary = CLDCloudinary(configuration: cldConfig!)
        
        // Extracts JPEG data from image of sighting
        var data = Data()
        data = UIImageJPEGRepresentation(sighting.image,0.7)!
        
        // Uploads image to cloudinary
        let params = CLDUploadRequestParams()
        _ = cloudinary.createUploader().upload(data: data, uploadPreset: "pyquajzw", params: params, progress: { (progress: Progress) in
            // Progress Handler
            print(progress.fractionCompleted)
        }) { (response, error) in
            // Complete Handler
            if error != nil {
                print("Couldn't upload image!")
            } else {
                print("Image uploaded!")
                // Creates new sighting in Firebase
                let newSighting = dbRef.childByAutoId()
                // Populates data about sighting in Firebase, including URL of image,
                // which was just returned in "response"
                newSighting.setValue(["lat": String(sighting.latitude), "long": String(sighting.longitude), "petType": sighting.petType, "imageURL": response?.publicId ?? "", "timestamp": sighting.timestamp.timeIntervalSinceReferenceDate])
                print(sighting.timestamp.timeIntervalSinceReferenceDate)
                
                // Calls completed callback to let parent function know everything was successful
                completed()
            }
        }
    }
    
    // Given current time and timestamp of sighting, generates user-friendly "spotted time"
    func generateSpottedTime() -> String? {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day,.minute,.hour], from: self.timestamp, to: date)
        let hour = components.hour
        let minute = components.minute
        let day = components.day
        
        var time: String? = nil
        if day! > 0 {
            time = String("Spotted \(day!) day(s) ago...")
        } else if hour! > 0 {
            time = String("Spotted \(hour!) hour(s) ago...")
        } else if minute! > 0 {
            time = String("Spotted \(minute!) minute(s) ago...")
        } else {
            time = String("Spotted right now...")
        }
        
        return time
    }
    
    // Generates new sighting list from Firebase dictionary
    static func generateSightingList(dictionary: [String : AnyObject]) -> [PetSighting] {
        
        var newList: [PetSighting] = []
        print("generate")
        for sighting in dictionary {
            print(sighting.value["petType"])
            print("Building pic for \(sighting.key)")
            // Gather important information about sighting from Firebase
            let value = sighting.value as? [String : AnyObject] ?? [:]
            let lat: Double = (value["lat"] as! NSString).doubleValue
            let long: Double = (value["long"] as! NSString).doubleValue
            let timestampNumber = value["timestamp"] as! Double
            print(timestampNumber)
            print("Lat \(lat)")
            print("Long \(long)")
            
            // Create sighting object
            let newSighting: PetSighting = PetSighting(petID: sighting.key, petType: (sighting.value["petType"] as? String)!, timestampNumber: timestampNumber, image: nil, latitude: lat, longitude: long, imageURL: (sighting.value["imageURL"] as? String)!)
            
            // Add sighting to list
            newList.append(newSighting)
        }
        
        return newList
    }
}
