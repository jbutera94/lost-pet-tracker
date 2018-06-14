//
//  ViewController.swift
//  Lost Pet Tracker
//
//  Created by Justin Butera on 5/10/17.
//  Copyright © 2017 Justin Butera. All rights reserved.
//

import UIKit
import UserNotifications

class MainMenuViewController: UIViewController {

    // Outlets
    @IBOutlet weak var reportAPetBtn: UIButton!
    @IBOutlet weak var mapBtn: UIButton!
    @IBOutlet weak var listingBtn: UIButton!
    
    // Asks for notification permissions if iOS 10 or greater
    func notificationPermissions() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert])
            { (success, error) in
                if success {
                    print("Granted")
                } else {
                    print("Error")
                }
            }
        } else {
            print("On < iOS 10")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationPermissions()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidLayoutSubviews() {
        
        // Changes buttons to round instead of square
        reportAPetBtn.layer.cornerRadius = 0.5 * reportAPetBtn.bounds.width
        reportAPetBtn.clipsToBounds = true
        
        mapBtn.layer.cornerRadius = 0.5 * mapBtn.bounds.width
        mapBtn.clipsToBounds = true
        
        listingBtn.layer.cornerRadius = 0.5 * listingBtn.bounds.width
        listingBtn.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

