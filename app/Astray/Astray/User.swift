//
//  User.swift
//  Astray
//
//  Created by Katherine Bernstein on 2/6/16.
//  Copyright © 2016 yes. All rights reserved.
//

import UIKit

class User {
    var username : String
    var bio : String
    var email : String
    var stumble : Bool
    var fbConnected : Bool
    
    init(username:String, bio:String, email:String) {
        self.username = username
        self.bio = bio
        self.email = email
        self.stumble = true
        self.fbConnected = false
    }
    
    func getUsername() -> String {
        return self.username
    }
    
    func getBio() -> String {
        return self.bio
    }
    
    func getEmail() -> String {
        return self.email
    }
    
    func getStumbleMode() -> Bool {
        return self.stumble
    }
    
    func getFbConnected() -> Bool {
        return self.fbConnected
    }
    
    func setBio(bio:String) {
        self.bio = bio
    }
    
    func setStumbleMode(stumble:Bool) {
        self.stumble = stumble
    }
    
    func setFbConnected(connected:Bool) {
        self.fbConnected = connected
    }
}
