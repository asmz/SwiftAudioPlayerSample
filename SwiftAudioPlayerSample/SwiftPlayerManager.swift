//
//  SwiftPlayerManager.swift
//  SwiftAudioPlayerSample
//
//  Created by abc on 2014/09/23.
//  Copyright (c) 2014年 asmz. All rights reserved.
//

import AVFoundation
import UIKit

class SwiftPlayerManager: NSObject, AVAudioPlayerDelegate {
    var player : AVAudioPlayer! = nil   // プレイヤー
    var title : String = ""             // タイトル
    var artist : String = ""            // アーティスト
    var album : String = ""             // アルバム
    var artwork : UIImage? = nil        // アートワーク
    
    // 初期化処理
    override init() {
        super.init()
        
        // 音声ファイルパス取得
        let audioPath = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("sample", ofType: "mp3")!)
        
        // 音声ファイル情報読み込み
        self.loadMetaDataFromAudioFile(audioPath!)
        
        // プレイヤー準備
        player = AVAudioPlayer(contentsOfURL: audioPath, error: nil)
        player.delegate = self
        player.enableRate = true    // 再生速度変更を有効化
        player.prepareToPlay()
    }

    // 再生／一時停止処理
    func playOrPause() {
        if (player.playing) {
            // 現在再生中なら一時停止
            player.pause()
        } else {
            // 現在再生していないなら再生
            player.play()
        }
    }
    
    // 再生終了時処理
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        player.stop()
        
        // 再生終了を通知
        let noti = NSNotification(name: "stop", object: self)
        NSNotificationCenter.defaultCenter().postNotification(noti)
    }
    
    // 再生速度変更
    func setRate(rate : Float) {
        // 引数に設定された再生速度をプレイヤーに設定
        player.rate = rate
    }
    
    // 再生位置変更
    func setPlayingTime(pos : Double) {
        // 引数に設定された再生位置をプレイヤーに設定
        player.currentTime = pos
    }
    
    // MP3ファイルからメタデータ読み込み
    func loadMetaDataFromAudioFile(url : NSURL) {
        let asset : AVAsset = AVURLAsset(URL:url, options: nil)
        let metadata : Array = asset.commonMetadata
        
        for item in metadata {
            switch item.commonKey as String {
            case AVMetadataCommonKeyTitle:
                // タイトル取得
                title = item.stringValue
            case AVMetadataCommonKeyAlbumName:
                // アルバム名取得
                album = item.stringValue
            case AVMetadataCommonKeyArtist:
                // アーティスト名取得
                artist = item.stringValue
            case AVMetadataCommonKeyArtwork:
                // アートワーク取得
                if let artworkData = item.value as? NSDictionary {
                    // iOS7まではNSDirectory型が返却される
                    artwork = UIImage(data:artworkData["data"] as NSData)
                } else {
                    // iOS8からはNSData型が返却される
                    artwork = UIImage(data:item.dataValue)
                }
            default:
                break
            }
        }
    }
}