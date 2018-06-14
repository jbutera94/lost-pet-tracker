//
//  SightingTableViewController.swift
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
import SDWebImage

class SightingsTableViewController: UITableViewController, CLLocationManagerDelegate {

    // New pet sightings list
    var petSightings: [PetSighting] = []
    
    // Firebase setup
    var dbRef: DatabaseReference!
    
    // Cloudinary setup
    let cldConfig = CLDConfiguration(cloudinaryUrl: "cloudinary://238511635694454:zISbNSrcKI1TUHAKEEAaU-L0DXc@jbutera94")
    var cloudinary: CLDCloudinary!
    
    // Outlet for table view
    @IBOutlet var listOfSightingsTableView: UITableView!
    
    // Setup location
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.locationManager.delegate = self
        cloudinary = CLDCloudinary(configuration: cldConfig!)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewwillappear")
        dbRef = Database.database().reference()
        dbRef.observe(DataEventType.value, with: {(snapshot: DataSnapshot) in
            print("value event")
            let dictionary = snapshot.value as? [String : AnyObject] ?? [:]
            self.petSightings = PetSighting.generateSightingList(dictionary: dictionary)
            print(self.petSightings)
            self.listOfSightingsTableView.reloadData()
            
            
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petSightings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SightingTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SightingTableViewCell else {
            fatalError("The dequeued cell is not an instance of SightingTableViewCell")
        }

        // Configure the table cell
        cell.isHidden = true
        cell.progressIndicator.hidesWhenStopped = true
        let sighting = petSightings[indexPath.row]
        cell.petID = sighting.petID
        cell.petPhotoImageVIew.contentMode = .scaleAspectFill
        let url = URL(string: cloudinary.createUrl().generate(sighting.imageURL!)!)
        print(url ?? "")
        cell.typeOfPetLabel.text = "Type of Pet: \(sighting.petType)"
        cell.progressIndicator.startAnimating()
        // Download image from cloudinary and set it to image view
        cell.petPhotoImageVIew.sd_setImage(with: url, placeholderImage: nil, options: [],completed: { (image, error, cacheType, imageURL) in
        cell.progressIndicator.stopAnimating()
        })
        cell.isHidden = false
        
        // Start recording location
        self.locationManager.startUpdatingLocation()

        return cell
    }
    
    // When a row is tapped, segue to details view, passing in sighting as sender
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let petSighting = PetSighting.findPetSighting(petID: (tableView.cellForRow(at: indexPath)! as! SightingTableViewCell).petID!, petSightings: self.petSightings)
        self.performSegue(withIdentifier: "TableCellToDetailsSegue", sender: petSighting)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If segueing to details view, set sighting in details view as the one that was tapped
        if segue.identifier == "TableCellToDetailsSegue" {
            if let destinationController = segue.destination as? SightingDetailsViewController {
                destinationController.sighting = sender as? PetSighting
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Stop recording location if view is no longer loaded
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        //var totalCells = 0
//        if listOfSightingsTableView.visibleCells.count > 0 {
//            totalCells = listOfSightingsTableView.visibleCells.count
//        }
        
        // When location is updated and there are sightings in table view,
        // update distances of each cell
        if listOfSightingsTableView.visibleCells.count != 0 {
            for index in 0...listOfSightingsTableView.visibleCells.count-1 {
                //let indexPath = IndexPath(row: index, section: 0)
                let cell = listOfSightingsTableView.visibleCells[index] as! SightingTableViewCell
                let cellSighting: PetSighting? = PetSighting.findPetSighting(petID: (cell.petID)!, petSightings: self.petSightings)
                let sightingLocation = CLLocation(latitude: (cellSighting?.latitude)!, longitude: (cellSighting?.longitude)!)
                let distance = currentLocation?.distance(from: sightingLocation)
                
                cell.distanceLabel.text = "\(String(round(distance! * 0.000621371 * 10)/10)) miles away"
                cell.timestampLabel.text = cellSighting?.generateSpottedTime()
                print(cell.timestampLabel.text ?? "")
            }
        }
        
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
