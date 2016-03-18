//
//  CreateAudioController.swift
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


class CreateAudioController: UIViewController, CLLocationManagerDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet weak var descriptionHolder: UITextField!
    @IBOutlet weak var titleHolder: UITextField!
    @IBOutlet weak var storyTitle: UITextField!
    @IBOutlet weak var storyDescription: UITextField!
    @IBOutlet weak var storyTextData: UITextField!
    @IBOutlet var storyData: String!
    @IBOutlet weak var uploadStoryButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    var pin: MKPointAnnotation!
    var radius: Double = minR+initDelta
    var radiusOverlay: MKCircle = MKCircle()
    var username: String?
    var userId: String?
    
    
    var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioURL: NSURL!
    var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("at audio view!")
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let currUid = appDelegate.currUid {
            
            
        
        }
    }
    
    func navigateToView(view:String) {
        if let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(view) {
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    
    @IBAction func recordAudio() {
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if allowed {
                        self.loadRecordingUI()
                        print("permission granted!")
                    } else {
                        // failed to record!
                        //
                        //                        audioRecorder.delegate = self
                        //                        audioRecorder.meteringEnabled = true
                        //                        audioRecorder.prepareToRecord()
                        //                        audioRecorder.record()
                    }
                }
            }
        } catch {
            // failed to record!
        }
        
    }
    
    @IBAction func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //    @IBAction func videoCreate() {
    //        self.navigateToView("RecordingView")
    //    }
    //
    func finishRecording(success success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            storyData = prepareRecording()
            recordButton.setTitle("Tap to Re-record", forState: .Normal)
        } else {
            recordButton.setTitle("Tap to Record", forState: .Normal)
            print("recording failed :(")
        }
    }
    
    func prepareRecording() -> String{
        let data = NSData(contentsOfURL: audioURL!)
        
        if data != "" {
            
            let encodeOption = NSDataBase64EncodingOptions(rawValue: 0)
            do {
                try NSFileManager.defaultManager().removeItemAtURL(audioURL)
            } catch {
                print("File could not be deleted from cache.")
            }
            return data!.base64EncodedStringWithOptions(encodeOption)
        }
        return ""
        
    }
    
    func loadRecordingUI() {
        recordButton = UIButton(frame: CGRect(x: 64, y: 64, width: 128, height: 64))
        recordButton.setTitle("Tap to Record", forState: .Normal)
        recordButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
        recordButton.setTitleColor(UIColor.darkGrayColor(), forState: UIControlState.Normal)
      
        recordButton.addTarget(self, action: "recordTapped", forControlEvents: .TouchUpInside)
        view.addSubview(recordButton)
    }
    
    
    func startRecording(){
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docDir = paths[0]
        let dataPath = (docDir as NSString).stringByAppendingPathComponent("audioFile4.m4a")
        audioURL = NSURL(fileURLWithPath: dataPath)
        
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        do {
            print(audioURL)
            audioRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            recordButton.setTitle("Tap to Stop", forState: .Normal)
            
        } catch {
            print("recorder couldn't be built")
            finishRecording(success: false)
        }
    }
    
    func recordTapped() {
        if audioRecorder == nil {
            print("starting recording")
            startRecording()
        } else {
            print("done with recording!")
            finishRecording(success: true)
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = manager.location {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            //self.mapView.setRegion(region, animated: true)
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            if let currUid = appDelegate.currUid {
                let myRootRef = Firebase(url:"https://astray194.firebaseio.com")
                let geoFire = GeoFire(firebaseRef: myRootRef)
                geoFire.setLocation(location, forKey: currUid)
            }
        }
    }
    
    @IBAction func uploadStoryButtonClicked() {
        print("uploadClicked!!")
        let rad = 0
        
        var lat = 0
        var long = 0
        let title = self.titleHolder.text
        let description = self.descriptionHolder.text
        

        let storyRef = Firebase(url:"")//"https://astray194.firebaseio.com/Stories")
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let storyInfo: NSDictionary = [
            "title": title!,
            "description": description!, //also fix title and filetype!!!
            
            "author_id": appDelegate.currUid!,
            "latitude": lat,
            "longitude": long,
            "radius": rad,
            //   "timestamp": NSDate(),
            "data": storyData,
            "fileType": "mp3"
        ]
        
        let childRef = storyRef.childByAutoId()
        childRef.setValue(storyInfo)
        
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
