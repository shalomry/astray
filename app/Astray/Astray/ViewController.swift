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
    @IBOutlet weak var notInRangeLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    
    @IBOutlet weak var pinInfoView: UIView!
    
    @IBOutlet weak var pinInfoContainer: UIView!
    
    
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
                
                let rootRef = Firebase(url:"https://astray194.firebaseio.com")
                let geoFire = GeoFire(firebaseRef: rootRef.childByAppendingPath("Geo"))
                rootRef.childByAppendingPath("Stories").observeEventType(.Value, withBlock: { snapshot in
                    for child in snapshot.children {
                        let storyKey = child.key
                        let storySnapshot = snapshot.childSnapshotForPath(storyKey)
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
                        
                        var query = geoFire.queryAtLocation(CLLocation(latitude: lat, longitude: long), withRadius: 0.1)
                        var addHandle = query.observeEventType(GFEventTypeKeyEntered, withBlock: { (key: String!, location: CLLocation!) in
                            print("Key '\(key)' entered the search area and is at '"+title)
                            let storiesRef = Firebase(url:"https://astray194.firebaseio.com/Users/"+key+"/availablestories")
                            storiesRef.childByAppendingPath(title).runTransactionBlock({
                                (currentData:FMutableData!) in
                                currentData.value = storyKey
                                return FTransactionResult.successWithValue(currentData)
                            })
                        })
                        var removeHandle = query.observeEventType(GFEventTypeKeyExited, withBlock: { (key: String!, location: CLLocation!) in
                            print("Key '\(key)' left '"+title)
                            let storiesRef = Firebase(url:"https://astray194.firebaseio.com/Users/"+key+"/availablestories")
                            storiesRef.childByAppendingPath(title).removeValue()
                        })

                    }
                })
            }
        } else {
            self.navigateToView("LoginView")
        }
    }
    
//    func slideUpFromBottom(duration: NSTimeInterval = 1.0, completionDelegate: AnyObject? = nil) {
//        let slideUpFromBottomTransition = CATransition()
//        if let delegate: AnyObject = completionDelegate {
//            slideUpFromBottomTransition.delegate = delegate
//        }
//        slideUpFromBottomTransition.type = kCATransitionPush
//        slideUpFromBottomTransition.subtype = kCATransitionFromBottom
//        slideUpFromBottomTransition.duration = duration
//        slideUpFromBottomTransition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
//        slideUpFromBottomTransition.fillMode = kCAFillModeRemoved
//        
//        self.layer.addAnimation(slideUpFromBottomTransition, forKey: "slideUpFromBottomTransition")
//    }
    
    func navigateToView(view:String) {
        if let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(view) {
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    @IBAction func createAStory() {
        self.navigateToView("CreateStoryView")
    }
    
    @IBAction func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if let currUid = appDelegate.currUid {
                let myRootRef = Firebase(url:"https://astray194.firebaseio.com/Geo")
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
    
    @IBAction func goToSearch() {
        self.navigateToView("SearchView")
    }
    
    func mapView(_ mapView: MKMapView,
        didSelectAnnotationView view: MKAnnotationView) {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            var title: String = ""
            if let aTitle = mapView.selectedAnnotations[0].title {
                title = aTitle!
            } else { return; }
            if (title == "Current Location") { return; }
            if let currUid = appDelegate.currUid {
                let url = "https://astray194.firebaseio.com/Users/"+currUid+"/availablestories/"+title
                let storyRef = Firebase(url:url)
                storyRef.observeEventType(.Value, withBlock: { snapshot in
                    print(snapshot.value)
                    if var key: String = snapshot.value as? String {
                        print("showing view story button")
                        self.pinInfoView.slideUpFromBottom()
                        self.viewStoryButton.hidden = false
                        self.notInRangeLabel.hidden = true
                        appDelegate.currStory = key
                    } else {
                        print("showing not in range label")
                        self.notInRangeLabel.hidden = false
                        self.viewStoryButton.hidden = true
                    }
                })
            }
    }

    func mapView(_ mapView: MKMapView,
        didDeselectAnnotationView view: MKAnnotationView) {
            self.viewStoryButton.hidden = true
            self.notInRangeLabel.hidden = true
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.currStory = nil
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
