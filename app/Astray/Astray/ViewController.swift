//
//  ViewController.swift
//  Astray
//
//  Created by Daniel Spaeth on 1/20/16.
//  Copyright © 2016 yes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Firebase
import GeoFire

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viewStoryButton: UIButton!
    
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
                
                let oval = CLLocationCoordinate2DMake(37.4299352, -122.169266)
                let ovalPin = MKPointAnnotation()
                ovalPin.coordinate = oval
                ovalPin.title = "The Oval"
                let lakelag = CLLocationCoordinate2DMake(37.4221486, -122.1766676)
                let lakelagPin = MKPointAnnotation()
                lakelagPin.coordinate = lakelag
                lakelagPin.title = "Lake Lag"
                let ikes = CLLocationCoordinate2DMake(37.4281014, -122.1742029)
                let ikesPin = MKPointAnnotation()
                ikesPin.coordinate = ikes
                ikesPin.title = "The Restaurant Formerly Known As Ike's"
                
                self.mapView.addAnnotation(ovalPin)
                self.mapView.addAnnotation(lakelagPin)
                self.mapView.addAnnotation(ikesPin)
                
                let myRootRef = Firebase(url:"https://astray194.firebaseio.com")
                let geoFire = GeoFire(firebaseRef: myRootRef)
                var ovalQuery = geoFire.queryAtLocation(CLLocation(latitude: 37.4299352, longitude: -122.169266), withRadius: 0.001)
                var ovalQueryHandle = ovalQuery.observeEventType(GFEventTypeKeyEntered, withBlock: { (key: String!, location: CLLocation!) in
                    print("Key '\(key)' entered the search area and is at the oval'")
                })
                
                var lakeLagQuery = geoFire.queryAtLocation(CLLocation(latitude: 37.4221486, longitude: -122.1766676), withRadius: 0.001)
                var lakeLagQueryHandle = lakeLagQuery.observeEventType(GFEventTypeKeyEntered, withBlock: { (key: String!, location: CLLocation!) in
                    print("Key '\(key)' entered the search area and is at lake lag'")
                })
                
                var ikesQuery = geoFire.queryAtLocation(CLLocation(latitude: 37.4281014, longitude: -122.1742029), withRadius: 0.001)
                var ikesQueryHandle = ikesQuery.observeEventType(GFEventTypeKeyEntered, withBlock: { (key: String!, location: CLLocation!) in
                    print("Key '\(key)' entered the search area and is at ikes'")
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
    

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            self.mapView.setRegion(region, animated: true)
            
            let oval = CLLocationCoordinate2DMake(37.4299352, -122.169266)
            let ovalPin = MKPointAnnotation()
            ovalPin.coordinate = oval
            ovalPin.title = "The Oval"
            let lakelag = CLLocationCoordinate2DMake(37.4221486, -122.1766676)
            let lakelagPin = MKPointAnnotation()
            lakelagPin.coordinate = lakelag
            lakelagPin.title = "Lake Lag"
            let ikes = CLLocationCoordinate2DMake(37.4281014, -122.1742029)
            let ikesPin = MKPointAnnotation()
            ikesPin.coordinate = ikes
            ikesPin.title = "The Restaurant Formerly Known As Ike's"
            let memchu = CLLocationCoordinate2DMake(37.4268187, -122.1705897)
            let memchuPin = MKPointAnnotation()
            memchuPin.coordinate = memchu
            memchuPin.title = "MemChu"
            let sf = CLLocationCoordinate2DMake(37.7889499,-122.4066867)
            let sfPin = MKPointAnnotation()
            sfPin.coordinate = sf
            sfPin.title = "sf"
            
        
            self.mapView.addAnnotation(ovalPin)
            self.mapView.addAnnotation(lakelagPin)
            self.mapView.addAnnotation(ikesPin)
            self.mapView.addAnnotation(memchuPin)
            self.mapView.addAnnotation(sfPin)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if let currUid = appDelegate.currUid {
                let myRootRef = Firebase(url:"https://astray194.firebaseio.com")
                let geoFire = GeoFire(firebaseRef: myRootRef)
                geoFire.setLocation(location, forKey: currUid)
            }
        }
    }
    
    @IBAction func goToStory() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if appDelegate.currStory != nil {
            self.navigateToView("NarrativeView")
        }
    }
    
    func mapView(_ mapView: MKMapView,
        didSelectAnnotationView view: MKAnnotationView) {
            self.viewStoryButton.hidden = false
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if let aTitle = mapView.selectedAnnotations[0].title {
                appDelegate.currStory = aTitle!
            }
    }
    
    func mapView(_ mapView: MKMapView,
        didDeselectAnnotationView view: MKAnnotationView) {
            self.viewStoryButton.hidden = true
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.currStory = nil
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
