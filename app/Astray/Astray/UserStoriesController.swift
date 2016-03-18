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
    
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var storyUsernameLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let currUid = appDelegate.currUid {
            if let viewingUid = appDelegate.viewingUid {
                self.viewingUid = viewingUid
            } else {
                self.viewingUid = currUid
            }
            
            if self.storyUsernameLabel != nil {
                let url = "https://astray194.firebaseio.com/Users/"+self.viewingUid!+"/username"
                let usernameRef = Firebase(url:url)
                usernameRef.observeEventType(.Value, withBlock: {
                    snapshot in
                    self.storyUsernameLabel.text = snapshot.value as! String + "'s Stories"
                })
            }
            
            if (CLLocationManager.locationServicesEnabled()) {
                locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
                
//                let userTrackingArrow = MKUserTrackingBarButtonItem(mapView: self.mapView)
//                self.toolbarItems = [userTrackingArrow]
//                self.navigationController?.setToolbarHidden(true, animated: false)
                mapView.showsUserLocation = true
                mapView.delegate = self
//                self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: false);
                
                print("getting stories")
                var pins = [MKAnnotation]()
                let rootRef = Firebase(url:"https://astray194.firebaseio.com")
                Firebase(url:"https://astray194.firebaseio.com/Stories").observeSingleEventOfType(.Value, withBlock: { snapshot in
                    print("whyyy")
                    for child in snapshot.children {
                        let storyKey = child.key
                        let storySnapshot = snapshot.childSnapshotForPath(storyKey)
                        print("currUid")
                        print(self.viewingUid)
                        print("storyAuthorId")
                        print(storySnapshot.value.objectForKey("author_id") as! String)
                        if (storySnapshot.value.objectForKey("author_id") as! String == self.viewingUid){
                            print("adding story")
                            print(storySnapshot.value.objectForKey("latitude"))
                            let lat = storySnapshot.value.objectForKey("latitude") as! Double
                            let long = storySnapshot.value.objectForKey("longitude") as! Double
                            let loc = CLLocationCoordinate2DMake(lat, long)
                            let pin = MKPointAnnotation()
                            pin.coordinate = loc
                            let title = storySnapshot.value.objectForKey("title") as! String
                            pin.title = title
                            self.mapView.addAnnotation(pin)
                            pins.append(pin)
                        }
                    }
                    self.mapView.showAnnotations(pins, animated: true)
                })
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

}