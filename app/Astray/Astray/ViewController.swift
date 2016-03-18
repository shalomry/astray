//
//  ViewController.swift
//  Astray
//
//  Created by Daniel Spaeth on 1/20/16.
//  Copyright © 2016 yes. All rights reserved.
//

import UIKit
import AudioToolbox
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
    
    
    
    var locationManager: CLLocationManager!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("LOADING VIEW CONROLLER")
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
       // appDelegate.stumbleMode = true
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
                if !appDelegate.stumbleMode {
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
                        
                            var query = geoFire.queryAtLocation(CLLocation(latitude: lat, longitude: long),     withRadius: 0.1)
                            var addHandle = query.observeEventType(GFEventTypeKeyEntered, withBlock: { (key: String!, location: CLLocation!) in
                            //print("Key '\(key)' entered the search area and is at '"+title)
                                let storiesRef = Firebase(url:"https://astray194.firebaseio.com/Users/"+key+"/availablestories")
                                storiesRef.childByAppendingPath(title).runTransactionBlock({
                                    (currentData:FMutableData!) in
                                    currentData.value = storyKey
                                    return FTransactionResult.successWithValue(currentData)
                                })
                            })
                            var removeHandle = query.observeEventType(GFEventTypeKeyExited, withBlock: { (key: String!, location: CLLocation!) in
                                //print("Key '\(key)' left '"+title)
                                let storiesRef = Firebase(url:"https://astray194.firebaseio.com/Users/"+key+"/availablestories")
                                storiesRef.childByAppendingPath(title).removeValue()
                            })

                        }
                    })
                    rootRef.childByAppendingPath("Users").childByAppendingPath(currUid).childByAppendingPath("availablestories").observeEventType(.ChildRemoved, withBlock: { snapshot in
                        print("NEW THING IN RANGE")
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        // story id = snapshot.value
                        print(snapshot.value)
                    })
                } else {
                    rootRef.childByAppendingPath("Users").childByAppendingPath(currUid).childByAppendingPath("availablestories").observeEventType(.ChildAdded, withBlock: { snapshot1 in
                        print("SNAPSHOT 1")
                        print(snapshot1)
                        print("SNAPSHOT DONE")
                        print(snapshot1.value)
                        let storyKey = snapshot1.value
                        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                        if (storyKey as! String).characters.count > 0 {
                            rootRef.childByAppendingPath("Stories").childByAppendingPath(storyKey as! String).observeSingleEventOfType(.ChildAdded, withBlock: { storySnapshot in
                                print("adding story")
                                print(storySnapshot)
                                print(storySnapshot.value.objectForKey("latitude"))
                                let lat = storySnapshot.value.objectForKey("latitude") as! Double
                                let long = storySnapshot.value.objectForKey("longitude") as! Double
                                let loc = CLLocationCoordinate2DMake(lat, long)
                                let pin = MKPointAnnotation()
                                pin.coordinate = loc
                                let title = storySnapshot.value.objectForKey("title") as! String
                                pin.title = title
                                self.mapView.addAnnotation(pin)
                                    
                                var query = geoFire.queryAtLocation(CLLocation(latitude: lat, longitude: long),     withRadius: 0.1)
                                var addHandle = query.observeEventType(GFEventTypeKeyEntered, withBlock: { (key: String!, location: CLLocation!) in
                                    //print("Key '\(key)' entered the search area and is at '"+title)
                                    let storiesRef = Firebase(url:"https://astray194.firebaseio.com/Users/"+key+"/availablestories")
                                        storiesRef.childByAppendingPath(title).runTransactionBlock({
                                            (currentData:FMutableData!) in
                                            currentData.value = storyKey
                                        return FTransactionResult.successWithValue(currentData)
                                    })
                                })
                                var removeHandle = query.observeEventType(GFEventTypeKeyExited, withBlock: { (key: String!, location: CLLocation!) in
                                    //print("Key '\(key)' left '"+title)
                                    let storiesRef = Firebase(url:"https://astray194.firebaseio.com/Users/"+key+"/availablestories")
                                    storiesRef.childByAppendingPath(title).removeValue()
                                })
                                    
                            })
                        
                        
                        }
                    })
                    rootRef.childByAppendingPath("Users").childByAppendingPath(currUid).childByAppendingPath("availablestories").observeEventType(.ChildRemoved, withBlock: { snapshot1 in
                        let titlesToRemove = NSMutableArray()
                        for storyKey in snapshot1.children {
                            if (storyKey as! String).characters.count > 0 {
                                rootRef.childByAppendingPath("Stories").childByAppendingPath(storyKey as! String).observeSingleEventOfType(.ChildAdded, withBlock: { storySnapshot in
                                    print("removing story")
                                    if let title = storySnapshot.value.objectForKey("title") {
                                        titlesToRemove.addObject(title)
                                    }
                                })
                            }
                        }
                        var annotationsToRemove = [MKAnnotation]()
                        for (pin) in self.mapView.annotations {
                            if titlesToRemove.containsObject(pin.title!!) {
                                annotationsToRemove.append(pin)
                            }
                        }
                        self.mapView.removeAnnotations(annotationsToRemove)
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
    
    @IBAction func goToProfile() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        print("CURRID: " + appDelegate.currUid!)
        self.navigateToView("ProfileView")
    }
    
    
    @IBAction func goToSearch() {
        self.navigateToView("SearchView")
    }
    

    func slideOutPinView() {
        self.pinInfoView.hidden = true
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
                    if let key: String = snapshot.value as? String {
                        print("showing view story button")
                        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.BeginFromCurrentState], animations: {
                            self.pinInfoView.frame.origin.y = 0
                            }, completion: nil)
                        self.pinInfoView.hidden = false
                        
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
            slideOutPinView()
            self.notInRangeLabel.hidden = true
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.currStory = nil
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
