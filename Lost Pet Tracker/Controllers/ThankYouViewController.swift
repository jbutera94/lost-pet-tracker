//
//  ThankYouViewController.swift
//  Lost Pet Tracker
//
//  Created by Justin Butera on 5/12/17.
//  Copyright © 2017 Justin Butera. All rights reserved.
//

import UIKit

class ThankYouViewController: UIViewController {

    @IBOutlet weak var checkmarkBackground: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var mainMenuBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        // Set checkmark background to be a circle
        checkmarkBackground.layer.cornerRadius = 0.5 * checkmarkBackground.bounds.width
        checkmarkBackground.clipsToBounds = true
        
        // Word wrap text
        textLabel.numberOfLines = 0
        textLabel.lineBreakMode = .byWordWrapping
        
        // Rounded corners to main menu button
        mainMenuBtn.layer.cornerRadius = 0.05 * mainMenuBtn.bounds.width
        mainMenuBtn.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
