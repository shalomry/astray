//
//  NarrativeViewController.swift
//  Astray
//
//  Created by Shalom Rottman-Yang on 2/1/16.
//  Copyright © 2016 yes. All rights reserved.
//

import UIKit
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
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
