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
    @IBOutlet weak var storyDescription: UILabel!
    @IBOutlet weak var storyBody: UILabel!
    
 //   @IBOutlet weak var titleOfStory: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if appDelegate.currStory != nil {
            let storyInfoRef = Firebase(url:"https://astray194.firebaseio.com/Stories/"+appDelegate.currStory!)
            storyInfoRef.observeSingleEventOfType(.Value, withBlock: { snap in
                let dict = snap.value as! NSDictionary
                let title = dict.valueForKey("title") as! String
                
                self.titleOfStory.text = "\(title)"
                  self.storyDescription.text = dict.valueForKey("description") as! String
                   self.storyBody.text = dict.valueForKey("data") as! String
                
                
                
                
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
        self.navigateToView("DiscoverView")
    }
    
    
    //TODO: check if this story was uploaded by the given user.
    //if so, show the delete button.
    func delete() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let currStory = appDelegate.currStory {
            let storyArray = NSMutableArray()
            storyArray.addObject(currStory)
            appDelegate.deleteStories(storyArray)
            self.navigateToView("ProfileView")
        }
    }
    
    
}



