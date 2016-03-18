//
//  TextViewController.swift
//  Astray
//
//  Created by Vehbi Deger Turan on 3/18/16.
//  Copyright © 2016 yes. All rights reserved.


import UIKit
import AVKit
import AVFoundation
import Firebase

class TextViewController: UIViewController {
    
    var payload: String!
   
    @IBOutlet weak var titleOfStory: UILabel!
//    @IBOutlet weak var storyDescription: UILabel!
    @IBOutlet weak var storyBody: UITextView!
    
    @IBOutlet weak var deleteStoryButton: UIButton!
  
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if appDelegate.currStory != nil {
            let storyInfoRef = Firebase(url:"https://astray194.firebaseio.com/Stories/"+appDelegate.currStory!)
            storyInfoRef.observeSingleEventOfType(.Value, withBlock: { snap in
                let dict = snap.value as! NSDictionary
                
                if((dict.valueForKey("author_id") as! String) != appDelegate.currUid!){
                    self.deleteStoryButton.hidden = true
                }
                
                let title = dict.valueForKey("title") as! String
                
                self.titleOfStory.text = "\(title)"
//                  self.storyDescription.text = dict.valueForKey("description") as! String
                self.storyBody.text = dict.valueForKey("data") as! String
                self.storyBody.textColor = UIColor(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1)
                self.storyBody.textContainer.lineFragmentPadding = 0;
                self.storyBody.textContainerInset = UIEdgeInsetsZero;
                
                
                
                
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
     
    }
    
        
    func navigateToView(view:String) {
        if let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(view) {
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    @IBAction func backToExplore() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func deleteClicked(sender: AnyObject) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        // TODO: ASK FOR CONFIRMATION!!!! DON'T JUST DELETE THE STORY...
        
        if let currStory = appDelegate.currStory {
            let storyArray = NSMutableArray()
            storyArray.addObject(currStory)
            appDelegate.deleteStories(storyArray)
            self.navigateToView("ProfileView")
        }
    }
    
}



