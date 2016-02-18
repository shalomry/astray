//
//  CreateStoryController.swift
//  Astray
//
//  Created by Katherine Bernstein on 2/16/16.
//  Copyright © 2016 yes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import GeoFire

class CreateStoryController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var storyTitle: UITextField!
    @IBOutlet weak var storyDescription: UITextField!
    @IBOutlet weak var createStoryButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    var username: String?
    var userId: String?
    
    var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let currUid = appDelegate.currUid {
            
            if (CLLocationManager.locationServicesEnabled()) {
                locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
                
                let userTrackingArrow = MKUserTrackingBarButtonItem(mapView: self.mapView)
                self.toolbarItems = [userTrackingArrow]
                self.navigationController?.setToolbarHidden(false, animated: false)
                mapView.showsUserLocation = true
                mapView.delegate = self
                self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: false);

                let myRootRef = Firebase(url:"https://astray194.firebaseio.com")
                let geoFire = GeoFire(firebaseRef: myRootRef)
                
                let ref = Firebase(url:"https://astray194.firebaseio.com/Users")
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                if let currUid = appDelegate.currUid {
                    userId = currUid
                    let currUserRef = ref.childByAppendingPath(currUid)
                    currUserRef.observeEventType(.Value, withBlock: { snapshot in
                        if let username = snapshot.value.objectForKey("username") {
                            self.username = "\(username)"
                        }
                    })
                }
            }
        } else {
            self.navigateToView("LoginView")
        }
    }
    
    func navigateToView(view:String) {
        if let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(view) {
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mapView.setRegion(region, animated: true)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if let currUid = appDelegate.currUid {
                let myRootRef = Firebase(url:"https://astray194.firebaseio.com")
                let geoFire = GeoFire(firebaseRef: myRootRef)
                geoFire.setLocation(location, forKey: currUid)
            }
        }
    }
    
    @IBAction func createStoryButtonClicked() {
        let lat = mapView.centerCoordinate.latitude
        let long = mapView.centerCoordinate.longitude
        
        // TODO: move lines 84-108 in viewcontroller here, incorporate story id in geofire handles
        let storyRef = Firebase(url:"https://astray194.firebaseio.com/Stories")
        let storyInfo: NSDictionary = [
            "title": self.storyTitle.text!,
            "description": self.storyDescription.text!,
            "author": self.username!,
            "author_id": self.userId!,
            "latitude": lat,
            "longitude": long
        ]
        let childRef = storyRef.childByAutoId()
        childRef.setValue(storyInfo)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        print("KEY:")
        print(childRef.key)
        appDelegate.currStory = childRef.key
        self.navigateToView("NarrativeView")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
