//
//  SwiftPlayerManager.swift
//  SwiftAudioPlayerSample
//
//  Created by abc on 2014/09/23.
//  Copyright (c) 2014年 asmz. All rights reserved.
//

import AVFoundation
import UIKit

class SwiftPlayerManager: NSObject {

    // MARK: - Variables

    var player: AVAudioPlayer!
    var title: String = ""
    var artist: String = ""
    var album: String = ""
    var artwork: UIImage? = nil

    // MARK: - Constructor

    override init() {
        super.init()
        
        // Get audio file path
        let audioPath = URL(fileURLWithPath: Bundle.main.path(forResource: "sample", ofType: "mp3")!)
        
        // load audio file
        self.loadMetaDataFromAudioFile(audioPath)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)

            // Prepare player
            self.player = try AVAudioPlayer(contentsOf: audioPath)
        } catch _ {
            fatalError("Initialization error.")
        }

        player.delegate = self
        player.enableRate = true    // Enable playing rate change
        player.prepareToPlay()
    }

    // MARK: - Internal methods

    func playOrPause() {
        if player.isPlaying {
            player.pause()
        } else {
            player.play()
        }
    }

    func setRate(_ rate: Float) {
        player.rate = rate
    }
    
    func setPlayingTime(_ pos: Double) {
        player.currentTime = pos
    }

    // MARK: - Private methods

    func loadMetaDataFromAudioFile(_ url: URL) {
        let asset: AVAsset = AVURLAsset(url: url, options: nil)
        let metadata: Array = asset.commonMetadata
        
        for item in metadata {
            switch item.commonKey {
            case AVMetadataKey.commonKeyTitle:
                title = item.stringValue!
            case AVMetadataKey.commonKeyAlbumName:
                album = item.stringValue!
            case AVMetadataKey.commonKeyArtist:
                artist = item.stringValue!
            case AVMetadataKey.commonKeyArtwork:
                artwork = UIImage(data: item.dataValue!)
            default:
                break
            }
        }
    }
}

extension SwiftPlayerManager: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.stop()

        // Send notification
        let notification = Notification(name: Notification.Name(rawValue: "stop"), object: self)
        NotificationCenter.default.post(notification)
    }

}
