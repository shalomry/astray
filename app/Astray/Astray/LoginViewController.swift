//
//  LoginViewController.swift
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

import Foundation

class LoginViewController : UIViewController, UIActionSheetDelegate {
    @IBOutlet var btLogin: UIButton!
    
    @IBOutlet weak var newUsernameField: UITextField!
    @IBOutlet weak var newEmailField: UITextField!
    @IBOutlet weak var newPasswordField: UITextField!
    @IBOutlet weak var loginPasswordField: UITextField!
    @IBOutlet weak var bioField: UITextField!
    @IBOutlet weak var loginEmailField: UITextField!
    var ref: Firebase!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Firebase(url:"https://astray194.firebaseio.com")
    }
    
    func createUser(email:String, password:String, username:String, bio:String) {
        ref.createUser(email, password: password,
            withValueCompletionBlock: { error, result in
                if error != nil {
                    // There was an error creating the account
                } else {
                    let uid = result["uid"] as? String
                    print("Successfully created user account with uid: \(uid)")
                    print(username)
                    print(uid!)
                    let usersRef = self.ref.childByAppendingPath("Users")
                    let newUserRef = usersRef.childByAppendingPath(uid!)
                    let user : NSDictionary = ["username":username, "bio":bio, "email":email]
                    newUserRef.setValue(user)
                }
        })
    }
    
    @IBAction func login(sender: UIButton) {
        print("tryna login")
        print(self.loginEmailField.text)
        print(self.loginPasswordField.text)
        if let email = self.loginEmailField.text, let password = self.loginPasswordField.text {
            loginUser(email, password: password)
        }
            
        
    
    }

    @IBAction func create(sender: UIButton) {
        print("tryna create account")
        if let email = self.newEmailField.text, let username = self.newUsernameField.text, let password = self.newPasswordField.text, let bio = self.bioField.text {
            createUser(email, password: password, username: username, bio: bio)
        }
        

    }

    func loginUser(email:String, password:String) {
        ref.authUser(email, password: password,
            withCompletionBlock: { error, authData in
                if error != nil {
                    // There was an error logging in to this account
                } else {
                    print("Successfully logged in \(email)")
                    print("uid: \(authData.uid)")
                    let usersRef = self.ref.childByAppendingPath("Users")
                    let currRef = usersRef.childByAppendingPath(authData.uid)
                    print(currRef.key)
                    
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.currUid = authData.uid
                    if let mainView = self.storyboard?.instantiateViewControllerWithIdentifier("DiscoverView") {
                        self.navigationController?.pushViewController(mainView, animated: true)
                    }
                }
        })
    }

    
//    func loginWithFacebook() {
//        ref.authWithOAuthPopup("facebook", function(error, authData) {
//            if (error) {
//                console.log("Login Failed!", error);
//            } else {
//                console.log("Authenticated successfully with payload:", authData)
//            }
//        });
//    }
    
    
}
