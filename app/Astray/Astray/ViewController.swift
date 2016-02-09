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

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
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
            let pinAnnotation = MKPointAnnotation()
            sfPin.setValue(pinAnnotation, forKey: "button")
            
        
            self.mapView.addAnnotation(ovalPin)
            self.mapView.addAnnotation(lakelagPin)
            self.mapView.addAnnotation(ikesPin)
            self.mapView.addAnnotation(memchuPin)
            self.mapView.addAnnotation(sfPin)
            
            
            
        }
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation is MKAnnotation {
            let pinButton = UIButton(type: UIButtonType.Custom) as UIButton
            pinButton.frame.size.width = 44
            pinButton.frame.size.height = 44
            pinButton.backgroundColor = UIColor.redColor()
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "sf")
            pinAnnotationView.leftCalloutAccessoryView = pinButton
            return pinAnnotationView
        }
        return nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

