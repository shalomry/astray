//
//  AppDelegate.swift
//  Astray
//
//  Created by Daniel Spaeth on 1/20/16.
//  Copyright © 2016 yes. All rights reserved.
//

import UIKit
import CoreData
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var currUid: String?
    var currStory: String?
    var viewingUid: String?
    var ref: Firebase!
    


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func deleteStories(storiesToDelete: NSArray) {
        let userRef = Firebase(url:"https://astray194.firebaseio.com/Users")
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FDataSnapshot {
                if let storiesSeen = rest.value.valueForKey("storiestheyveseen") as? NSArray {
                    let newStoriesSeen = NSMutableArray()
                    newStoriesSeen.addObject("")
                    for (story) in storiesSeen {
                        if (story as! String).characters.count > 0 {
                            if !storiesToDelete.containsObject(story) {
                                newStoriesSeen.addObject(story)
                            }
                        }
                    }
                    userRef.childByAppendingPath(rest.key + "/storiestheyveseen").setValue(newStoriesSeen)
                }
                
                if let availableStories = rest.value.valueForKey("availablestories") as? NSArray {
                    let newAvailableStories = NSMutableArray()
                    newAvailableStories.addObject("")
                    for (story) in availableStories {
                        if (story as! String).characters.count > 0 {
                            if !storiesToDelete.containsObject(story) {
                                newAvailableStories.addObject(story)
                            }
                        }
                    }
                    userRef.childByAppendingPath(rest.key + "/availablestories").setValue(newAvailableStories)
                }
                
                if rest.key == self.currUid {
                    if let storiesCreated = rest.value.valueForKey("listofcreatedstories") as? NSArray {
                        let newStoriesCreated = NSMutableArray()
                        newStoriesCreated.addObject("")
                        for (story) in storiesCreated {
                            if (story as! String).characters.count > 0 {
                                if !storiesToDelete.containsObject(story) {
                                    newStoriesCreated.addObject(story)
                                }
                            }
                        }
                        userRef.childByAppendingPath(rest.key + "/listofcreatedstories").setValue(newStoriesCreated)
                    }
                }
            }
        })
        
        for (storyId) in storiesToDelete {
            let storyRef = Firebase(url:"https://astray194.firebaseio.com/Stories/"+(storyId as! String))
            storyRef.removeValue()
        }
        
    }


}

