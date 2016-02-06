//
//  NarrativeViewController.swift
//  Astray
//
//  Created by Shalom Rottman-Yang on 2/1/16.
//  Copyright © 2016 yes. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class NarrativeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sample = NSBundle.mainBundle().URLForResource("sample", withExtension: "mp3")
        
        do{
            let audioPlayer = try AVAudioPlayer(contentsOfURL:sample!)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
            print("played audio")
        }catch {
            print("Error getting the audio file")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func back() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private var firstAppear = true
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if firstAppear {
            do {
                try playVideo()
                firstAppear = false
            } catch AppError.InvalidResource(let name, let type) {
                debugPrint("Could not find resource \(name).\(type)")
            } catch {
                debugPrint("Generic error")
            }
            
        }
    }
    
    private func playVideo() throws {
        guard let path = NSBundle.mainBundle().pathForResource("samplevideo", ofType:"mov") else {
            throw AppError.InvalidResource("samplevideo", "mov")
        }
        let player = AVPlayer(URL: NSURL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        self.presentViewController(playerController, animated: true) {
            player.play()
        }
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}

enum AppError : ErrorType {
    case InvalidResource(String, String)
}
