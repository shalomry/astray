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
    @IBOutlet weak var loginPasswordField: UITextField!
    @IBOutlet weak var loginEmailField: UITextField!
    var ref: Firebase!
    
    @IBOutlet weak var loginErrorMessage: UILabel!
    let unknownEmailMsg = "Oops! We couldn't find the specified email address."
    let invalidPasswordMsg = "Oops! The password you entered is incorrect."
    let invalidEmailMsg = "The specified email address is invalid."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("VIEW DID LOAD")
        ref = Firebase(url:"https://astray194.firebaseio.com")
        
        if self.loginErrorMessage != nil {
            self.loginErrorMessage.text = ""
        }
    }
    
    func navigateToView(view:String) {
        if let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(view) {
            print("could instantiate")
            self.navigationController?.pushViewController(nextView, animated: true)
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
        self.navigateToView("CreateAccountView")
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
