//
//  ViewController.swift
//  VideoRecognition
//
//  Created by syj on 2017/7/21.
//  Copyright © 2017年 syj. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class ViewController: UIViewController {

    //初始化一个识别器
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    public  var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private var player = AVQueuePlayer()
    private let playerLayer = AVPlayerLayer()
    private var tap: MYAudioTapProcessor!
    
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
                self.setupRecognition()
            }
            
//            //path
//            let url = Bundle.main.url(forResource: "video", withExtension: "mp4")
//            
//            //初始化一个识别请求
//            let request = SFSpeechURLRecognitionRequest(url: url!)
//            
//            //开始一个识别请求
//            self.speechRecognizer.recognitionTask(with: request, resultHandler: { (result, error) in
//                if error != nil{
//                    print("识别错误")
//                    return
//                }
//                else{
//                    print(result?.bestTranscription.formattedString)
//                }
//            })
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
        
        tap = MYAudioTapProcessor(audioAssetTrack: audioTrack)
        tap.delegate = self
        
        // Video playback
        let item = AVPlayerItem(asset: asset)
        player.insert(item, after: nil)
        player.play()
        player.currentItem?.audioMix = tap.audioMix
        playerLayer.player = player
        playerLayer.frame = playerView.bounds;
        playerView.layer.insertSublayer(playerLayer, at: 0)
    }
    
    private func setupRecognition() {
        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        // we want to get continuous recognition and not everything at once at the end of the video
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [unowned self] result, error in
            
            self.textView.text = result?.bestTranscription.formattedString
            print("text:", result?.bestTranscription.formattedString);
            // once in about every minute recognition task finishes so we need to set up a new one to continue recognition
            if result?.isFinal == true {
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.setupRecognition()
            }
        }
        self.recognitionRequest = recognitionRequest
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: MYAudioTabProcessorDelegate {
    func audioTabProcessor(_ audioTabProcessor: MYAudioTapProcessor!, hasNewLeftChannelValue leftChannelValue: Float, rightChannelValue: Float) {
//        recognitionRequest?.append(buffer)
    }


    // getting audio buffer back from the tap and feeding into speech recognizer
    @available(iOS 8.0, *)
    func audioTabProcessor(_ audioTabProcessor: MYAudioTapProcessor!, didReceive buffer: AVAudioPCMBuffer!) {
        recognitionRequest?.append(buffer)
    }
}

