//
//  Story.swift
//  Astray
//
//  Created by Daniel Spaeth on 2/7/16.
//  Copyright © 2016 yes. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreLocation

class Story {
    var id: Int64
    var username : String
    var title: String
    var data: String
    var fileType: String
    var description: String
    var author: String
    var authorId: String
    var radius: Double
    var location: CLLocation
    var time: NSDate
    
    
    init(location:CLLocation) {
        //get from database
        self.id=1
        self.username="username"
        self.title="title"
        self.data="data"
        self.fileType="type"
        self.description="description"
        self.author="author"
        self.authorId="authorId"
        self.radius = 0.1
        self.location=CLLocation()
        self.time=NSDate()
    }
    
    func getId() -> Int64 {
        return self.id
    }
    
    func getUsername() -> String {
        return self.username
    }
    
    func getTitle() -> String {
        return self.title
    }
    
    func getData() -> String {
        return self.data
    }
    
    func getFileType() -> String{
        return self.fileType
    }
    
    func getDescription() -> String {
        return self.description
    }
    
    func getAuthor() -> String {
        return self.author
    }
    
    func getAuthorId() -> String {
        return self.authorId
    }
    
    func getRadius() -> Double{
        return self.radius
    }
    
    func getLocation() -> CLLocation {
        return self.location
    }
    
    func getTime() -> NSDate {
        return self.time
    }
}








