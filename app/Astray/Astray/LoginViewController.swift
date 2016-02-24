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
    
    @IBOutlet weak var loginErrorMessage: UILabel!
    @IBOutlet weak var createAccountErrorMessage: UILabel!
    let unknownEmailMsg = "Oops! We couldn't find the specified email address."
    let invalidPasswordMsg = "Oops! The password you entered is incorrect."
    let invalidEmailMsg = "The specified email address is invalid."
    let emailTakenMsg = "An account with that email already exists."
    let noUsernameMsg = "You must choose a username."
    let passwordTooShortMsg = "Your password must be at least 8 characters long."
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("VIEW DID LOAD")
        ref = Firebase(url:"https://astray194.firebaseio.com")
        
        if self.loginErrorMessage != nil {
            self.loginErrorMessage.text = ""
        }
        if self.createAccountErrorMessage != nil {
            self.createAccountErrorMessage.text = ""
        }
    }
    
    func navigateToView(view:String) {
        if let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(view) {
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    func createUser(email:String, password:String, username:String, bio:String) {
        if username.characters.count == 0 {
            self.createAccountErrorMessage.text = self.noUsernameMsg
        } else if password.characters.count < 8 {
            self.createAccountErrorMessage.text = self.passwordTooShortMsg
        } else {
            
            self.ref.createUser(email, password: password,
                withValueCompletionBlock: { error, result in
                    if error != nil {
                        if error.code == -5 {
                            self.createAccountErrorMessage.text = self.invalidEmailMsg
                        } else if error.code == -9 {
                            self.createAccountErrorMessage.text = self.emailTakenMsg
                        }
                    
                    } else {
                        let uid = result["uid"] as? String
                        print("Successfully created user account with uid: \(uid)")
                        print(username)
                        print(uid!)
                        let usersRef = self.ref.childByAppendingPath("Users")
                        let newUserRef = usersRef.childByAppendingPath(uid!)
                        let user : NSDictionary = [
                            "username":username,
                            "bio":bio,
                            "email":email,
                            "listofcreatedstories": ["0":""] as NSDictionary,
                            "storiestheyveseen": ["0":""] as NSDictionary,
                            "availablestories":["0":""] as NSDictionary
                        ]
                        newUserRef.setValue(user)
                        self.navigateToView("LoginView")
                    }
                }
            )
        }
    }
    
    @IBAction func login(sender: UIButton) {
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
                    if error.code == -5 {
                        self.loginErrorMessage.text = self.unknownEmailMsg
                    } else if error.code == -6 {
                        self.loginErrorMessage.text = self.invalidPasswordMsg
                    }
                } else {
                    print("Successfully logged in \(email)")
                    print("uid: \(authData.uid)")
                    let usersRef = self.ref.childByAppendingPath("Users")
                    let currRef = usersRef.childByAppendingPath(authData.uid)
                    print(currRef.key)
                    
                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    appDelegate.currUid = authData.uid
                    self.navigateToView("DiscoverView")
                }
        })
    }
    
    override func viewWillAppear(animated: Bool) {
    //COMMENT IN TO BRING BACK AUTH
        //    self.navigationItem.setHidesBackButton(true, animated:true)
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
