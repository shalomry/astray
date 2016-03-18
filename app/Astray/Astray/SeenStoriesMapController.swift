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
    
    
    @IBOutlet weak var pinInfoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let currUid = appDelegate.currUid {
            if let viewingUid = appDelegate.viewingUid {
                
                // load pins for storiestheyveseen where id = viewingUid
                
            }
        }
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
                //TODO: Set UID in url to uid of clicked story author
                let url = "https://astray194.firebaseio.com/Users/"+currUid+"/availablestories/"+title
                let storyRef = Firebase(url:url)
                storyRef.observeEventType(.Value, withBlock: { snapshot in
                    if let key: String = snapshot.value as? String {
                        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [UIViewAnimationOptions.CurveEaseInOut, UIViewAnimationOptions.BeginFromCurrentState], animations: {
                            self.pinInfoView.frame.origin.y = 0
                            }, completion: nil)
                        self.pinInfoView.hidden = false
                        appDelegate.currStory = key
                    }
                })
            }
    }
    
    func mapView(_ mapView: MKMapView,
        didDeselectAnnotationView view: MKAnnotationView) {
            self.pinInfoView.hidden = true
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.currStory = nil
    }
}