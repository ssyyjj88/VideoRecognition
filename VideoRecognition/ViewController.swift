//
//  ViewController.swift
//  VideoRecognition
//
//  Created by syj on 2017/7/21.
//  Copyright © 2017年 syj. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {

    //初始化一个识别器
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
//    private var tap: MYAudioTapProcessor!
    private var player = AVQueuePlayer()
    private let playerLayer = AVPlayerLayer()
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var playerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        SFSpeechRecognizer.requestAuthorization { status in
            print(status)
            
            assert(status == .authorized)
            DispatchQueue.main.async {
                self.setupVideo()
//                self.setupRecognition()
            }
            
            //path
            let url = Bundle.main.url(forResource: "video", withExtension: "mp4")
            
            //初始化一个识别请求
            let request = SFSpeechURLRecognitionRequest(url: url!)
            
            //开始一个识别请求
            self.speechRecognizer.recognitionTask(with: request, resultHandler: { (result, error) in
                if error != nil{
                    print("识别错误")
                    return
                }
                else{
                    print(result?.bestTranscription.formattedString)
                }
            })
        }
    }
    
    private func setupVideo() {
        // Asset
        let URL = Bundle.main.url(forResource: "video", withExtension: "mp4")!
        let asset = AVURLAsset(url: URL)
        let audioTrack = asset.tracks(withMediaType: AVMediaTypeAudio).first!
        
        // Tap
        // Slightly modified audio tap sample https://developer.apple.com/library/ios/samplecode/AudioTapProcessor/Introduction/Intro.html#//apple_ref/doc/uid/DTS40012324-Intro-DontLinkElementID_2
        // Takes AVAssetTrack and produces AVAudioPCMBuffer
        // great thanks to AVFoundation, CoreFoundation and SpeechKit engineers for helping to figure this out!
        // especially to Eric Lee for explaining how to convert AudioBufferList -> AVAudioPCMBuffer
        
//        tap = MYAudioTapProcessor(audioAssetTrack: audioTrack)
//        tap.delegate = self
        
        // Video playback
        let item = AVPlayerItem(asset: asset)
        player.insert(item, after: nil)
        player.play()
//        player.currentItem?.audioMix = tap.audioMix
        playerLayer.player = player
        playerLayer.frame = playerView.bounds;
        playerView.layer.insertSublayer(playerLayer, at: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

