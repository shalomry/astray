//
//  UserStoriesController.swift
//  Astray
//
//  Created by Katherine Bernstein on 3/17/16.
//  Copyright © 2016 yes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import GeoFire

class UserStoriesController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var viewingUid: String?
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let currUid = appDelegate.currUid {
            if let viewingUid = appDelegate.viewingUid {
                self.viewingUid = viewingUid
            } else {
                self.viewingUid = currUid
            }
            
            // load pins for user with uid = self.viewingUid
        }
    }

}