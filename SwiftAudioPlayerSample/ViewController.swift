//
//  ViewController.swift
//  SwiftAudioPlayerSample
//
//  Created by abc on 2014/09/23.
//  Copyright (c) 2014年 asmz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let manager = SwiftPlayerManager()          // 再生管理クラス
    @IBOutlet var btnPlayPause : UIButton?      // 再生／一時停止ボタン
    @IBOutlet var labelRate : UILabel?          // 再生速度ラベル
    @IBOutlet var labelPlayingTime : UILabel?   // 現在再生時間ラベル
    @IBOutlet var labelTotalTime : UILabel?     // 総再生時間ラベル
    @IBOutlet var labelTitle : UILabel?         // 音声タイトルラベル
    @IBOutlet var labelAlbum : UILabel?         // アルバムラベル
    @IBOutlet var labelArtist : UILabel?        // アーティストラベル
    @IBOutlet var imgArtwork : UIImageView?     // アートワークビュー
    @IBOutlet var sliderRate : UISlider?        // 再生速度変更スライダー
    @IBOutlet var sliderPlayingTime : UISlider? // 再生時間スライダー
    
    var playingTimeTimer : Timer?             // 再生時間監視タイマー
    
    // 再生／一時停止ボタン押下時アクション
    @IBAction func btnPlayAction() {
        // 管理クラスに再生／一時停止を伝達
        manager.playOrPause()
        
        // 再生／一時停止ボタン押下時挙動
        if manager.player.isPlaying {
            // 再生中なら「Pause」表示
            btnPlayPause!.setTitle("Pause", for: .normal)
            
            // 再生時間監視タイマー開始
            if (playingTimeTimer == nil) {
                playingTimeTimer = Timer.scheduledTimer(
                    timeInterval: 1,
                    target: self,
                    selector: #selector(ViewController.updatePlayingTime),
                    userInfo: nil,
                    repeats: true
                )
            }
        } else {
            // 再生していないなら「Play」表示
            btnPlayPause!.setTitle("Play", for: .normal)
            
            // 再生時間監視タイマー終了
            playingTimeTimer!.invalidate()
            playingTimeTimer = nil
        }
    }
    
    // 再生速度変更スライダー操作時アクション
    @IBAction func sliderRateAction() {
        // 管理クラスにスライダー設定値を伝達
        manager.setRate(sliderRate!.value)
        
        // ラベルに倍速値を設定
        labelRate!.text = String(format: "%.1f倍速", sliderRate!.value)
    }
    
    // 再生時間スライダー操作時アクション
    @IBAction func sliderPlayingTimeAction() {
        manager.setPlayingTime(Double(sliderPlayingTime!.value))
        self.updatePlayingTime()
    }
    
    // 再生終了通知検知時処理
    @objc func audioStopAction() {
        // 「Play」表示に戻す
        btnPlayPause!.setTitle("Play", for: .normal)
        
        // 再生時間監視タイマー終了
        playingTimeTimer!.invalidate()
        playingTimeTimer = nil
        
        // 再生時間スライダーを最初に戻す
        updatePlayingTime()
    }
    
    // 再生時間更新処理
    @objc func updatePlayingTime() {
        // 再生中の時間を各コントロールに設定
        sliderPlayingTime!.value = Float(manager.player.currentTime)
        labelPlayingTime!.text = self.formatTimeString(manager.player.currentTime)
    }
    
    // 指定された再生位置を「hh:mm:ss」形式にフォーマットして返す
    func formatTimeString(_ d: Double) -> String {
        let h : Int = Int(d / 3600)
        let m : Int = Int((d - Double(h) * 3600) / 60)
        let s : Int = Int(d - 3600 * Double(h)) - m * 60
        let str = String(format: "%02d:%02d:%02d", h, m, s)
        
        return str
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 再生終了通知を監視
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(ViewController.audioStopAction), name: NSNotification.Name(rawValue: "stop"), object: nil)
        
        // 各コントロールに音声ファイルの長さを設定
        sliderPlayingTime!.maximumValue = Float(manager.player.duration)
        labelTotalTime!.text = self.formatTimeString(manager.player.duration)
        
        // ID3タグ内容を各コントロールに反映
        labelTitle!.text = manager.title
        labelAlbum!.text = manager.album
        labelArtist!.text = manager.artist
        imgArtwork!.image = manager.artwork
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
