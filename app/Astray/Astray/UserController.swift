//
//  UserController.swift
//  Astray
//
//  Created by Katherine Bernstein on 2/8/16.
//  Copyright © 2016 yes. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Firebase
import CoreData
import MapKit
import CoreLocation

class UserController : UIViewController, UIActionSheetDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    
    var ref: Firebase!
    var uid: String?
    var username: String?
    var email: String?
    @IBOutlet weak var newBioField: UITextView!
    @IBOutlet weak var profileUsernameLabel: UILabel!
    @IBOutlet weak var profileBioLabel: UILabel!
    @IBOutlet weak var settingsUsernameLabel: UILabel!
    @IBOutlet weak var storyUsernameLabel: UILabel!
    @IBOutlet weak var profileEmailLabel: UILabel!
    @IBOutlet weak var newEmailField: UITextField!
    @IBOutlet weak var goToStoriesButton: UIButton!
    @IBOutlet weak var passwordConfirmation: UITextField!
    @IBOutlet weak var settingsError: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var favoritesButton: UIButton!
    
    @IBOutlet weak var mapView: MKMapView!
    let invalidPasswordText = "The password you entered was incorrect."
    let invalidEmailText = "Please enter a valid email address."
    let emailTakenText = "An account with that email already exists."
    let deleteErrorText = "You must enter your password to delete your account."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Firebase(url:"https://astray194.firebaseio.com/Users")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if self.settingsError != nil {
            self.settingsError.text = ""
        }
        print("IN USERCONTROLLER")
//        appDelegate.viewingUid = "1c5ac729-2507-4247-82f1-48f6d9fd525d"
        if let viewingUid = appDelegate.viewingUid {
            print("SETTING VIEWINGUID")
            self.uid = viewingUid
        } else if let currUid = appDelegate.currUid {
            print("SETTING CURRUID")
            self.uid = currUid
        }
        print("GOT HERE")
//        if appDelegate.viewingUid == appDelegate.currUid {
//            followButton.hidden = true
//            favoritesButton.hidden = false
//            // TODO: HIDE OPTION TO EDIT PROFILE
//        } else {
//            followButton.hidden = false
//            favoritesButton.hidden = true
//        }
        if uid != nil {
            if (self.mapView != nil) {
                if (CLLocationManager.locationServicesEnabled()) {
                    locationManager = CLLocationManager()
                    locationManager.delegate = self
                    locationManager.desiredAccuracy = kCLLocationAccuracyBest
                    locationManager.requestAlwaysAuthorization()
                    locationManager.startUpdatingLocation()
                    
                    //                let userTrackingArrow = MKUserTrackingBarButtonItem(mapView: self.mapView)
                    //                self.toolbarItems = [userTrackingArrow]
                    //                self.navigationController?.setToolbarHidden(true, animated: false)
                    mapView.showsUserLocation = true
                    mapView.delegate = self
                    //                self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: false);
            }
            
                
                print("getting stories")
                var pins = [MKAnnotation]()
                let rootRef = Firebase(url:"https://astray194.firebaseio.com")
                Firebase(url:"https://astray194.firebaseio.com/Stories").observeSingleEventOfType(.Value, withBlock: { snapshot in
                    print("whyyy")
                    for child in snapshot.children {
                        let storyKey = child.key
                        let storySnapshot = snapshot.childSnapshotForPath(storyKey)
                        print("currUid")
                        print(self.uid)
                        print("storyAuthorId")
                        //print(storySnapshot.value.objectForKey("author_id") as! String)
                        if (storySnapshot.value.objectForKey("author_id") as! String == self.uid){
                            print("adding story")
                            //print(storySnapshot.value.objectForKey("latitude"))
                            let lat = storySnapshot.value.objectForKey("latitude") as! Double
                            let long = storySnapshot.value.objectForKey("longitude") as! Double
                            let loc = CLLocationCoordinate2DMake(lat, long)
                            let pin = MKPointAnnotation()
                            pin.coordinate = loc
                            let title = storySnapshot.value.objectForKey("title") as! String
                            pin.title = title
                            if (self.mapView != nil) {self.mapView.addAnnotation(pin)}
                            pins.append(pin)
                        }
                    }
                    if (self.mapView != nil) {self.mapView.showAnnotations(pins, animated: true)}
                })
            }
            let currUserRef = ref.childByAppendingPath(uid)
            currUserRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                if let username = snapshot.value.objectForKey("username") {
                    self.username = "\(username)"
                    if self.profileUsernameLabel != nil {
                        self.profileUsernameLabel.text = "\(username)"
                        self.profileUsernameLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
                        self.profileUsernameLabel.layer.shadowRadius = 5
                        self.profileUsernameLabel.layer.shadowOpacity = 1.0
                    }
                    if self.settingsUsernameLabel != nil {
                        self.settingsUsernameLabel.text = "\(username)"
                    }
                    if self.storyUsernameLabel != nil {
                        self.storyUsernameLabel.text = "\(username)"
                    }
//                    if self.goToStoriesButton != nil {
//                        let title = "\(username)'s Stories"
//                        self.goToStoriesButton.setTitle(title, forState: .Normal)
//                    }
//                    if self.followButton != nil {
//                        self.followButton.setTitle("Follow \(username)", forState: .Normal)
//                    }
                }
                if let bio = snapshot.value.objectForKey("bio") {
                    if self.newBioField != nil {
                        self.newBioField.text = "\(bio)"
                    }
                    if self.profileBioLabel != nil {
                        self.profileBioLabel.text = "\(bio)"
                        self.profileBioLabel.lineBreakMode = .ByWordWrapping
                        self.profileBioLabel.numberOfLines = 0
                        self.profileBioLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
                        self.profileBioLabel.layer.shadowRadius = 5
                        self.profileBioLabel.layer.shadowOpacity = 1.0
                    }
                }
                if let email = snapshot.value.objectForKey("email") {
                    self.email = "\(email)"
                    if self.newEmailField != nil {
                        self.newEmailField.text = "\(email)"
                    }
                    if self.profileEmailLabel != nil {
                        self.profileEmailLabel.text = "\(email)"
                        
                        self.profileEmailLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
                        self.profileEmailLabel.layer.shadowRadius = 5
                        self.profileEmailLabel.layer.shadowOpacity = 1.0
                    }
                }
                if appDelegate.viewingUid != appDelegate.currUid && appDelegate.viewingUid != nil {
                    if self.followButton != nil {
                        self.followButton.hidden = false
                    }
                    if self.favoritesButton != nil {
                        self.favoritesButton.hidden = true
                    }
                    if let following = snapshot.value.objectForKey("followers") {
                        print(following)
                        if (self.followButton != nil) {
                            if let image = UIImage(named: "follow-button.tiff") {
                                self.followButton.setImage(image, forState: .Normal)
                            }
                            for (id) in following as! NSArray {
                                if id as! String == appDelegate.currUid {
                                    if let image = UIImage(named: "unfollow-button.tiff") {
                                        self.followButton.setImage(image, forState: .Normal)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if self.followButton != nil {
                        self.followButton.hidden = true
                    }
                    if self.favoritesButton != nil {
                        self.favoritesButton.hidden = false
                    }
                }
            })
            
            
            
        }
    }
    
    func navigateToView(view:String) {
        if let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(view) {
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    @IBAction func goToFavorites() {
        self.navigateToView("FavoritesView")
    }
    
    
    @IBAction func goToStories() {
        self.navigateToView("ProfileMapView")
    }
    
    @IBAction func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func follow() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let currUid = appDelegate.currUid {
            let currUserRef = ref.childByAppendingPath(currUid)
            let profileUserRef = ref.childByAppendingPath(uid)
            currUserRef.observeSingleEventOfType(.Value, withBlock: { snapshot1 in
                if let following = snapshot1.value.objectForKey("following") as? NSArray {
                    profileUserRef.observeSingleEventOfType(.Value, withBlock: { snapshot2 in
                        if let followers = snapshot2.value.objectForKey("followers") as? NSArray {
                            let newFollowing: NSMutableArray = NSMutableArray()
                            let newFollowers: NSMutableArray = NSMutableArray()
                            for (follower) in followers {
                                if follower as! String != currUid {
                                    newFollowers.addObject(follower)
                                }
                            }
                            for (follow) in following {
                                if follow as! String != self.uid {
                                    newFollowing.addObject(follow)
                                }
                            }

                            if self.followButton.titleLabel?.text == "Follow" {
                                newFollowing.addObject(self.uid!)
                                newFollowers.addObject(currUid)
                            }
                            
                            currUserRef.childByAppendingPath("following").setValue(newFollowing)
                            profileUserRef.childByAppendingPath("followers").setValue(newFollowers)
                        }
                    })
                }
            })
        }
    }
    
    @IBAction func logout() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.currUid = nil
        self.navigateToView("LoginView")
    }
    
    @IBAction func updateProfile() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let currUid = appDelegate.currUid {
            let currUserRef = ref.childByAppendingPath(currUid)
            if let currUid = appDelegate.currUid {
                let currUserRef = ref.childByAppendingPath(currUid)
                currUserRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                    if let email = snapshot.value.objectForKey("email") {
                        if self.newEmailField.text != "\(email)" {
                            let ref = Firebase(url:"https://astray194.firebaseio.com")
                            ref.changeEmailForUser("\(email)", password: self.passwordConfirmation.text, toNewEmail: self.newEmailField.text, withCompletionBlock: { error in
                                if error != nil {
                                    self.settingsError.text = "Please enter a valid email address."
                                    if error.code == -5 {
                                        self.settingsError.text = self.invalidEmailText
                                    } else if error.code == -6 {
                                        self.settingsError.text = self.invalidPasswordText
                                    } else if error.code == -9 {
                                        self.settingsError.text = self.emailTakenText
                                    }
                                } else {
                                    let emailRef = currUserRef.childByAppendingPath("email")
                                    emailRef.setValue(self.newEmailField.text)
                                    let bioRef = currUserRef.childByAppendingPath("bio")
                                    bioRef.setValue(self.newBioField.text)
                                    self.navigateToView("ProfileView")
                                }
                            })
                        } else {
                            let bioRef = currUserRef.childByAppendingPath("bio")
                            bioRef.setValue(self.newBioField.text)
                            self.navigateToView("ProfileView")
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func confirmDelete() {
        //TODO: confirm i.e. "are you sure you want to delete your account?"
        if true {
            deleteUser(self.newEmailField.text!, password: self.passwordConfirmation.text!)
            self.navigateToView("LoginView")
        }
    }
    
    func deleteUser(email: String, password: String) {
        let authRef = Firebase(url:"https://astray194.firebaseio.com")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        authRef.authUser(email, password: password,
            withCompletionBlock: { error, authData in
                if error != nil {
                    self.settingsError.text = self.deleteErrorText
                } else {
        
                    if let currUid = appDelegate.currUid {
                        
                        let currUserRef = self.ref.childByAppendingPath(currUid)
                        let userHandle = currUserRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
                    
                            if let favorites = snapshot.value.objectForKey("following") as? NSArray {
                                for (favorite) in favorites {
                                    if (favorite as! String).characters.count > 0 {
                                        let favoriteRef = self.ref.childByAppendingPath(favorite as! String)
                                        let newFavFollowers = NSMutableArray()
                                        newFavFollowers.addObject("")
                                        favoriteRef.observeSingleEventOfType(.Value, withBlock: { snapshot1 in
                                            if let favFollowers = snapshot1.value.objectForKey("followers") as? NSArray {
                                                for (follower) in favFollowers {
                                                    if (follower as! String).characters.count > 0 {
                                                        if follower as! String != currUid {
                                                            newFavFollowers.addObject(follower)
                                                        }
                                                    }
                                                }
                                                favoriteRef.childByAppendingPath("followers").setValue(newFavFollowers)
                                            }
                                        })
                                    }
                                }
                            }

                            if let followers = snapshot.value.objectForKey("followers") as? NSArray {
                                for (follower) in followers {
                                    if (follower as! String).characters.count > 0 {
                                        let followerRef = self.ref.childByAppendingPath(follower as! String)
                                        let newFollowerFavs = NSMutableArray()
                                        newFollowerFavs.addObject("")
                                        followerRef.observeSingleEventOfType(.Value, withBlock: { snapshot2 in
                                            if let followerFavs = snapshot2.value.objectForKey("following") as? NSArray {
                                                for (favorite) in followerFavs {
                                                    if (favorite as! String).characters.count > 0 {
                                                        if favorite as! String != currUid {
                                                            newFollowerFavs.addObject(favorite)
                                                        }
                                                    }
                                                }
                                                followerRef.childByAppendingPath("following").setValue(newFollowerFavs)
                                            }
                                        })
                                    }
                                }
                            }
                    
                            if let storiesCreated = snapshot.value.objectForKey("listofcreatedstories") as? NSArray {
                                appDelegate.deleteStories(storiesCreated)
                            }
                        }, withCancelBlock: { error in
                                print(error.description)
                        })

                        authRef.removeUser(email, password: password,
                            withCompletionBlock: { error in
                                if error != nil {
                                    self.settingsError.text = self.deleteErrorText
                                } else {
                                    let userRef = Firebase(url:"https://astray194.firebaseio.com/Users/" + appDelegate.currUid!)
                                    userRef.removeValue()
                                    appDelegate.currUid = nil
                                }
                        
                            
                        })
                    }
                }
        })
    }
}