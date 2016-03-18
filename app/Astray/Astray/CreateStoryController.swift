//
//  CreateStoryController.swift
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

let minR = 1.0
let maxDelta = 100.0
let initDelta = 50.0

class CreateStoryController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, AVAudioRecorderDelegate {
    
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
    
    //@IBOutlet weak var sliderRadius: UISlider!
    
    
    
    var recordButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioURL: NSURL!
    var locationManager: CLLocationManager!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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
        
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let currUid = appDelegate.currUid {
            
            if (CLLocationManager.locationServicesEnabled()) {
                locationManager = CLLocationManager()
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
                
                let userTrackingArrow = MKUserTrackingBarButtonItem(mapView: self.mapView)
                self.toolbarItems = [userTrackingArrow]
                self.navigationController?.setToolbarHidden(false, animated: false)
                mapView.showsUserLocation = true
                mapView.delegate = self
                self.mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: false);
                
                let myRootRef = Firebase(url:"https://astray194.firebaseio.com")
                let geoFire = GeoFire(firebaseRef: myRootRef)
                
                let ref = Firebase(url:"https://astray194.firebaseio.com/Users")
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                if let currUid = appDelegate.currUid {
                    userId = currUid
                    let currUserRef = ref.childByAppendingPath(currUid)
                    currUserRef.observeEventType(.Value, withBlock: { snapshot in
                        if let username = snapshot.value.objectForKey("username") {
                            self.username = "\(username)"
                        }
                    })
                }
            }
            
            var pin = MKPointAnnotation()
            pin.coordinate = mapView.centerCoordinate;
            self.pin = pin
            mapView.addAnnotation(self.pin)
            
            var circle = MKCircle(centerCoordinate: self.pin.coordinate, radius: self.radius)
            self.radiusOverlay = circle
            self.mapView.addOverlay(self.radiusOverlay)
            
            let lpgr = UILongPressGestureRecognizer(target: self, action:"handleLongPress:")
            lpgr.minimumPressDuration = 0.5
            lpgr.delaysTouchesBegan = true
            self.mapView.addGestureRecognizer(lpgr)
            
        } else {
            self.navigateToView("LoginView")
        }
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        var overlayRenderer : MKCircleRenderer = MKCircleRenderer(overlay: overlay);
        overlayRenderer.lineWidth = 1.0
        overlayRenderer.strokeColor = UIColor.redColor()
        return overlayRenderer
    }
    
    func updateOverlay() {
        self.mapView.removeOverlay(self.radiusOverlay)
        self.radiusOverlay = MKCircle(centerCoordinate: self.pin.coordinate, radius: self.radius)
        self.mapView.addOverlay(radiusOverlay)
    }
    
    @IBAction func radiusSlider(sender: UISlider) {
        var currentValue = Double(sender.value)
        var currR = currentValue*maxDelta+minR
        self.radius = currR
        updateOverlay()
    }
    
    @IBAction func handleLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state != UIGestureRecognizerState.Began { return }
        let touchLocation = sender.locationInView(mapView)
        let locationCoordinate = mapView.convertPoint(touchLocation, toCoordinateFromView: mapView)
        print("Tapped at lat: \(locationCoordinate.latitude) long: \(locationCoordinate.longitude)")
//        if (self.pin != nil) {
//            self.mapView.removeAnnotation(self.pin)
//        }
//        self.mapView.setUserTrackingMode(MKUserTrackingMode.None, animated: false);
//        var pin = MKPointAnnotation()
//        pin.coordinate = locationCoordinate;
//        self.pin = pin;
//        self.mapView.addAnnotation(self.pin);
        self.mapView.setCenterCoordinate(locationCoordinate, animated: true);
    }
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        self.pin.coordinate = mapView.centerCoordinate;
        updateOverlay()
    }
    
    func navigateToView(view:String) {
        if let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(view) {
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    @IBAction func goBack() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func videoCreate() {
        self.navigateToView("RecordingView")
    }
    
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
                print("OMG FILE COULDNT BE DELETED WTHH")
            }
            return data!.base64EncodedStringWithOptions(encodeOption)
        }
        return ""
       
    }
    
    func loadRecordingUI() {
        recordButton = UIButton(frame: CGRect(x: 64, y: 64, width: 128, height: 64))
        recordButton.setTitle("Tap to Record", forState: .Normal)
        recordButton.titleLabel?.font = UIFont.preferredFontForTextStyle(UIFontTextStyleTitle1)
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
        let rad = self.radius
        
        var lat = mapView.centerCoordinate.latitude
        var long = mapView.centerCoordinate.longitude
        
        if (self.pin != nil) {
            lat = self.pin.coordinate.latitude
            long = self.pin.coordinate.longitude
        }
        
        let storyRef = Firebase(url:"https://astray194.firebaseio.com/Stories")
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        
        do{
            let storyInfo: NSDictionary = [
                "title": "titleofastory",
           //     "description": self.storyDescription.text!, //also fix title and filetype!!!
              
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
            
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            print("KEY:")
            print(childRef.key)
            appDelegate.currStory = childRef.key
            self.navigateToView("DiscoverView") //or should we go back to discover view instead??
        }
        catch {
            print("videoData could not be uploaded.")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
