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
import AVFoundation

let minR = 1.0
let maxDelta = 100.0
let initDelta = 50.0

class CreateStoryController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet weak var storyTitle: UITextField!
    @IBOutlet weak var storyDescription: UITextField!
    @IBOutlet weak var storyTextData: UITextField!
    @IBOutlet var storyData: String!
    @IBOutlet weak var uploadStoryButton: UIButton!
    @IBOutlet weak var TEMPBUTTON: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    var pin: MKPointAnnotation!
    var radius: Double = minR+initDelta
    var radiusOverlay: MKCircle = MKCircle()
    var username: String?
    var userId: String?
    
    
    var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioURL: NSURL!
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
                
                var pin = MKPointAnnotation()
                pin.coordinate = mapView.centerCoordinate;
                self.pin = pin
                mapView.addAnnotation(self.pin)
                
                var circle = MKCircle(centerCoordinate: self.pin.coordinate, radius: self.radius)
                self.radiusOverlay = circle
                self.mapView.addOverlay(self.radiusOverlay)
                
                let lpgr = UILongPressGestureRecognizer(target: self, action:"handleLongPress:")
                lpgr.minimumPressDuration = 0.5
                lpgr.delaysTouchesBegan = true
                self.mapView.addGestureRecognizer(lpgr)
                
            } else {
                self.navigateToView("LoginView")
            }
        
    }
    
    func navigateToView(view:String) {
        if let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(view) {
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    func collectData(){
        storyInfo.radius = self.radius
        storyInfo.lat = mapView.centerCoordinate.latitude
        storyInfo.long = mapView.centerCoordinate.longitude
    }
    
    @IBAction func createVideo() {
        collectData()
        navigateToView("VideoCreateView")
    }
    
    @IBAction func createText() {
        collectData()
        navigateToView("TextCreateView")
    }
    
    @IBAction func createAudio() {
        collectData()
        navigateToView("AudioCreateView")
    }
    
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        var overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
        overlayRenderer.lineWidth = 1.0
        overlayRenderer.strokeColor = UIColor.blueColor()
        return overlayRenderer
    }
    
    func updateOverlay() {
        self.mapView.removeOverlay(self.radiusOverlay)
        self.radiusOverlay = MKCircle(centerCoordinate: self.pin.coordinate, radius: self.radius)
        self.mapView.addOverlay(radiusOverlay)
    }
    
    @IBAction func radiusSlider(sender: UISlider) {
        var currentValue = Double(sender.value)
        var currR = currentValue*maxDelta+minR
        self.radius = currR
        updateOverlay()
    }
    
    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.Began { return }
        let touchLocation = sender.locationInView(mapView)
        let locationCoordinate = mapView.convertPoint(touchLocation, toCoordinateFromView: mapView)
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
//        if (self.pin != nil) {
//            self.mapView.removeAnnotation(self.pin)
//        }
//        self.mapView.setUserTrackingMode(MKUserTrackingMode.None, animated: false);
//        var pin = MKPointAnnotation()
//        pin.coordinate = locationCoordinate;
//        self.pin = pin;
//        self.mapView.addAnnotation(self.pin);
        self.mapView.setCenterCoordinate(locationCoordinate, animated: true);
    }
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        self.pin.coordinate = mapView.centerCoordinate;
        updateOverlay()
    }
    
    @IBAction func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
        
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            //self.mapView.setRegion(region, animated: true)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if let currUid = appDelegate.currUid {
                let myRootRef = Firebase(url:"https://astray194.firebaseio.com")
                let geoFire = GeoFire(firebaseRef: myRootRef)
                geoFire.setLocation(location, forKey: currUid)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
