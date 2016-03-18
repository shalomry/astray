//
//  CreateTextController.swift
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


class CreateTextController: UIViewController, CLLocationManagerDelegate, AVAudioRecorderDelegate {
    
    
    @IBOutlet weak var titleHolder: UITextField!
    
    
    @IBOutlet weak var descriptionHolder: UITextField!
    
    @IBOutlet weak var bodyHolder: UITextField!
    
    @IBOutlet weak var uploadStoryButton: UIButton!
    @IBOutlet weak var backToCreateButton: UIButton!
    
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        print("at audio view!")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
    }
    
    func navigateToView(view:String) {
        if let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(view) {
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    
    @IBAction func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func backToCreate(sender: AnyObject) {
        self.navigateToView("CreateStoryView")
    }
    
    @IBAction func uploadStoryButtonClicked() {
        print("uploadClicked!!")
        let title = self.titleHolder.text
        let description = self.descriptionHolder.text
        let storyData = self.bodyHolder.text
        
        
        let storyRef = Firebase(url:"https://astray194.firebaseio.com/Stories")
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let storyBundle: NSDictionary = [
            "title": title!,
            "description": description!,
            
            "author_id": appDelegate.currUid!,
            "latitude": storyInfo.lat,
            "longitude": storyInfo.long,
            "radius": storyInfo.radius,
            //   "timestamp": NSDate(),
            "data": storyData!,
            "fileType": "txt"
        ]
        
        let childRef = storyRef.childByAutoId()
        childRef.setValue(storyBundle)
        
        print("KEY:")
        print(childRef.key)
        appDelegate.currStory = childRef.key
        self.navigateToView("DiscoverView")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
