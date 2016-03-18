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


class CreateTextController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate, AVAudioRecorderDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var titleHolder: UITextField!
    @IBOutlet weak var descriptionHolder: UITextView!
    @IBOutlet weak var bodyHolder: UITextView!
    @IBOutlet weak var uploadStoryButton: UIButton!
    
    var placeHolderTextDesc = "description"
    var placeHolderTextBody = "body"
        
    override func viewDidLoad() {
        super.viewDidLoad()
        print("at audio view!")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        descriptionHolder.delegate = self
        bodyHolder.delegate = self
        titleHolder.delegate = self
        
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        
        print("CLICKED")

        if(textView.text == placeHolderTextDesc || textView.text == placeHolderTextBody) {
            print("PASSEDTEST")
            textView.text = ""
        }
        
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if(textView.text == "" && textView == bodyHolder) {
            bodyHolder.text = placeHolderTextBody
        } else if (textView.text == "" && textView == descriptionHolder) {
            descriptionHolder.text = placeHolderTextDesc
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        descriptionHolder.textColor = UIColor(red: 12.0/255.0, green: 18.0/255.0, blue: 24.0/255.0, alpha: 1)
        descriptionHolder.text = placeHolderTextDesc
        descriptionHolder.textContainer.lineFragmentPadding = 0;
        descriptionHolder.textContainerInset = UIEdgeInsetsZero;
        bodyHolder.textColor = UIColor(red: 12.0/255.0, green: 18.0/255.0, blue: 24.0/255.0, alpha: 1)
        bodyHolder.text = placeHolderTextBody
        bodyHolder.textContainer.lineFragmentPadding = 0;
        bodyHolder.textContainerInset = UIEdgeInsetsZero;
        
    }
    
    func navigateToView(view:String) {
        if let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(view) {
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    
    @IBAction func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func uploadStoryButtonClicked() {
        print("uploadClicked!!")
        let title = self.titleHolder.text
        let description = self.descriptionHolder.text
        let storyData = self.bodyHolder.text
        
        
        let storyRef = Firebase(url:"https://astray194.firebaseio.com/Stories")
        
        let time =  NSDate()
        let cal = NSCalendar.currentCalendar()
        let comps = cal.components([.Day , .Month , .Year], fromDate: time)
        let timestamp = String(comps.month)+"/"+String(comps.day)+"/"+String(comps.year)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let storyBundle: NSDictionary = [
            "title": title!,
            "description": description!,
            
            "author_id": appDelegate.currUid!,
            "latitude": storyInfo.lat,
            "longitude": storyInfo.long,
            "radius": storyInfo.radius,
            "timestamp": timestamp,
            "data": storyData!,
            "fileType": "txt",
            "viewCount": 0
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
