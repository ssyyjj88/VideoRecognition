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
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var playerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        SFSpeechRecognizer.requestAuthorization { status in
            print(status)
            
            assert(status == .authorized)
            DispatchQueue.main.async {
//                self.setupVideo()
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

