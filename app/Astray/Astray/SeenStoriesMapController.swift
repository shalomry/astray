//
//  SeenStoriesMapController.swift
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

class SeenStoriesMapController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var viewingUid: String?
    var locationManager: CLLocationManager!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let currUid = appDelegate.currUid {
            if let viewingUid = appDelegate.viewingUid {
                
                // load pins for storiestheyveseen where id = viewingUid
                
            }
        }
    }
}