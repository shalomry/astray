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
import AVKit
import AVFoundation


class CreateAudioController: UIViewController, UITextViewDelegate, CLLocationManagerDelegate, AVAudioRecorderDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var titleHolder: UITextField!
    @IBOutlet weak var currTime: UILabel!
    @IBOutlet weak var descriptionHolder: UITextView!
    @IBOutlet weak var durationTime: UILabel!
    @IBOutlet weak var trackBar: CustomUISlider!
    @IBOutlet weak var recordButton: UIButton!
    var storyData: String!

    var finishedRecordingSuccessfully = false
    
    @IBOutlet weak var playPause: UIButton!
   
    var playerReal: AVPlayer! = AVPlayer()
    var playerItemReal: AVPlayerItem!
    var playing = false
    
    var fileURL: NSURL!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioURL: NSURL!
    var locationManager: CLLocationManager!
    
    var timer : NSTimer!
    
    var placeHolderTextDesc = "description"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("at audio view!")
        self.titleHolder.delegate = self
        self.descriptionHolder.delegate = self
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let currUid = appDelegate.currUid {
            
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
                        }
                    }
                }
            } catch {
                // failed to record!
            }
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateBar", userInfo: nil, repeats: true)
        
        trackBar.addTarget(self, action: Selector("trackBarMoved"), forControlEvents: UIControlEvents.ValueChanged)

        descriptionHolder.delegate = self
    }
    
    func textFieldShouldReturn(textField: UITextField!) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?){
        view.endEditing(true)
        super.touchesBegan(touches, withEvent: event)
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        textView.text = ""
        
        return true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if(textView.text == "") {
            descriptionHolder.text = placeHolderTextDesc
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        descriptionHolder.textColor = UIColor(red: 12.0/255.0, green: 18.0/255.0, blue: 24.0/255.0, alpha: 1)
        descriptionHolder.text = placeHolderTextDesc
        descriptionHolder.textContainer.lineFragmentPadding = 0;
        descriptionHolder.textContainerInset = UIEdgeInsetsZero;
    }
    
    func navigateToView(view:String) {
        if let nextView = self.storyboard?.instantiateViewControllerWithIdentifier(view) {
            self.navigationController?.pushViewController(nextView, animated: true)
        }
    }
    
    @IBAction func backToCreate(sender: UIButton) {
        do {
            try NSFileManager.defaultManager().removeItemAtURL(audioURL)
        } catch {
            print("File could not be deleted from cache.")
        }
        goBack()
    }
    
    @IBAction func goBack() {
        finishedRecordingSuccessfully = false
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func finishRecording(success success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            storyData = prepareRecording()
            do{
                try replayAudioSetup()
            }
            catch{
                print("Couldn't construct replay audio setup.")
            }
            finishedRecordingSuccessfully = true
            if let image = UIImage(named: "record-new-track.tiff") {
                recordButton.setImage(image, forState: .Normal)
            }
        } else {
            if let image = UIImage(named: "record-new-track.tiff") {
                recordButton.setImage(image, forState: .Normal)
            }
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
        recordButton.addTarget(self, action: "recordTapped", forControlEvents: .TouchUpInside)
    }
    
    
    func startRecording(){
        
        finishedRecordingSuccessfully = false
        
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
            if let image = UIImage(named: "stop-recording.tiff") {
                recordButton.setImage(image, forState: .Normal)
            }
            
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
        let title = self.titleHolder.text
        let description = self.descriptionHolder.text
        
        let time =  NSDate()
        let cal = NSCalendar.currentCalendar()
        let comps = cal.components([.Day , .Month , .Year], fromDate: time)
        let timestamp = String(comps.month)+"/"+String(comps.day)+"/"+String(comps.year)

        
        let storyRef = Firebase(url:"https://astray194.firebaseio.com/Stories")
        
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        let storyBundle: NSDictionary = [
            "title": title!,
            "description": description!,
            "author_id": appDelegate.currUid!,
            "latitude": storyInfo.lat,
            "longitude": storyInfo.long,
            "radius": storyInfo.radius,
            "timestamp": timestamp,
            "data": storyData,
            "fileType": "mp3"
        ]
        
        let childRef = storyRef.childByAutoId()
        childRef.setValue(storyBundle)
        
        print("KEY:")
        print(childRef.key)
        appDelegate.currStory = childRef.key
        self.navigateToView("DiscoverView")
        
    }
    
    
    
    @IBAction func controlReplayAudio() {
        if(finishedRecordingSuccessfully){
            if playing {
                playerReal.pause()
                if let image = UIImage(named: "play-button.tiff") {
                    playPause.setImage(image, forState: .Normal)
                }
            } else {
                playerReal.play()
                if let image = UIImage(named: "pause-button.tiff") {
                    playPause.setImage(image, forState: .Normal)
                }
            }
            playing = !playing
        }
    }
    
    func trackBarMoved() {
        if (finishedRecordingSuccessfully) {
            timer.invalidate()
            let durDuration = (playerReal.currentItem?.asset.duration)!
            let durSecs = CMTimeGetSeconds(durDuration)
            let trackValue = self.trackBar.value
            playerReal.seekToTime(CMTimeMakeWithSeconds(Float64(trackValue) * durSecs, 1))
            timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "updateBar", userInfo: nil, repeats: true)
        }
    }
    
    func updateBar() {
        if (finishedRecordingSuccessfully) {
        let barValue : Float = Float(CMTimeGetSeconds(playerReal.currentTime())) / Float(CMTimeGetSeconds((playerReal.currentItem?.asset.duration)!))
        
        self.trackBar.value = barValue
        
        let currMin = Int(CMTimeGetSeconds((playerReal.currentTime()))) / 60
        let currSec = Int(CMTimeGetSeconds((playerReal.currentTime()))) % 60
        var currSecString = String(currSec)
        if currSec < 10 {
            currSecString = "0" + currSecString
        }
        currTime.text = String(currMin) + ":" + currSecString
        
        let durDuration = (playerReal.currentItem?.asset.duration)!
        let durSecs = CMTimeGetSeconds(durDuration)
        
        let durationMin = Int(durSecs) / 60
        let durationSec = Int(CMTimeGetSeconds((playerReal.currentItem?.asset.duration)!)) % 60
        var durationSecString = String(durationSec)
        if durationSec < 10 {
            durationSecString = "0" + durationSecString
        }
        durationTime.text = String(durationMin) + ":" + durationSecString
        }
    }
    
    func resetAudio() {
        playerReal.pause()
        playerReal.seekToTime(CMTimeMake(0, 1))
        if let image = UIImage(named: "play-button.tiff") {
            playPause.setImage(image, forState: .Normal)
        }
    }
    
    private var firstAppear = true
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        playing = false
        playerReal.pause()
        playerReal.seekToTime(CMTimeMake(0, 1))
    }

    
    private func replayAudioSetup() throws {
        
                let decodeOption = NSDataBase64DecodingOptions(rawValue: 0)
                let decodedData = NSData(base64EncodedString: storyData, options: decodeOption)
                
                let paths = NSSearchPathForDirectoriesInDomains(.CachesDirectory, .UserDomainMask, true)
                let docDir = paths[0]
                let dataPath = (docDir as NSString).stringByAppendingPathComponent("cacheddata.mp3")
                
                decodedData!.writeToFile(dataPath, atomically: true)
                self.fileURL = NSURL(fileURLWithPath: dataPath)
                self.playerItemReal = AVPlayerItem(URL: self.fileURL)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioDone", name: AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItemReal)
        
                self.playerReal = AVPlayer(playerItem: self.playerItemReal)
                let playerController = AVPlayerViewController()
                playerController.player = self.playerReal

    }
    
    func audioDone() {
        resetAudio()
        playing = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
