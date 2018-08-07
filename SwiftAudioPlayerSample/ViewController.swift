//
//  ViewController.swift
//  SwiftAudioPlayerSample
//
//  Created by abc on 2014/09/23.
//  Copyright (c) 2014年 asmz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Variables

    private let manager = SwiftPlayerManager()
    private var playingTimeTimer : Timer?

    // MARK: - IBOutlets

    @IBOutlet var playPauseButton : UIButton!
    @IBOutlet var rateLabel : UILabel!
    @IBOutlet var playingTimeLabel : UILabel!
    @IBOutlet var totalTimeLabel : UILabel!
    @IBOutlet var titleLabel : UILabel!
    @IBOutlet var albumLabel : UILabel!
    @IBOutlet var artistLabel : UILabel!
    @IBOutlet var artworkImageView : UIImageView!
    @IBOutlet var rateSlider : UISlider!
    @IBOutlet var playingTimeSlider : UISlider!

    // MARK: - IBActions

    @IBAction func didTapPlayPauseButton() {
        // Send control to manager
        self.manager.playOrPause()

        if self.manager.player.isPlaying {
            self.playPauseButton.setTitle("Pause", for: .normal)

            // Start timer
            if self.playingTimeTimer == nil {
                self.playingTimeTimer = Timer.scheduledTimer(
                    timeInterval: 1,
                    target: self,
                    selector: #selector(self.updatePlayingTime),
                    userInfo: nil,
                    repeats: true
                )
            }
        } else {
            self.playPauseButton.setTitle("Play", for: .normal)
            
            // Stop timer
            self.playingTimeTimer?.invalidate()
            self.playingTimeTimer = nil
        }
    }
    
    @IBAction func didChangeRateSlider() {
        self.manager.setRate(self.rateSlider.value)
        self.rateLabel.text = String(format: "x %.1f", self.rateSlider.value)
    }
    
    @IBAction func didChangePlayingTimeSlider() {
        self.manager.setPlayingTime(Double(self.playingTimeSlider.value))
        self.updatePlayingTime()
    }

    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()

        // Observe audio stop
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(self.didStopAudio), name: NSNotification.Name(rawValue: "stop"), object: nil)

        // Set audio length
        self.playingTimeSlider.maximumValue = Float(self.manager.player.duration)
        self.totalTimeLabel.text = self.formatTimeString(self.manager.player.duration)
        
        // Set mp3 tags
        self.titleLabel.text = self.manager.title
        self.albumLabel.text = self.manager.album
        self.artistLabel.text = self.manager.artist
        self.artworkImageView.image = self.manager.artwork
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Selector

    @objc func didStopAudio() {
        self.playPauseButton.setTitle("Play", for: .normal)

        // Stop timer
        self.playingTimeTimer?.invalidate()
        self.playingTimeTimer = nil

        self.updatePlayingTime()
    }

    @objc func updatePlayingTime() {
        self.playingTimeSlider.value = Float(self.manager.player.currentTime)
        self.playingTimeLabel.text = self.formatTimeString(self.manager.player.currentTime)
    }

    // MARK: - Private methods

    // Format to "hh:mm:ss"
    func formatTimeString(_ d: Double) -> String {
        let h : Int = Int(d / 3600)
        let m : Int = Int((d - Double(h) * 3600) / 60)
        let s : Int = Int(d - 3600 * Double(h)) - m * 60
        let str = String(format: "%02d:%02d:%02d", h, m, s)

        return str
    }
}
