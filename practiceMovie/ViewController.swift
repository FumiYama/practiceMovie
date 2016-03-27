//
//  ViewController.swift
//  practiceMovie
//
//  Created by Fumiya Yamanaka on 2016/01/12.
//  Copyright © 2016年 Fumiya Yamanaka. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

class ViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    private var vo_videoOutput: AVCaptureMovieFileOutput! //ビデオアウトプット
    private var sb_startButton: UIButton = UIButton() //スタートボタン
    private var sb_stopButton: UIButton = UIButton() // ストップボタン

    override func viewDidLoad() {
        super.viewDidLoad()
        let sw_screenWidth = self.view.frame.size.width
        let sh_screenHeight = self.view.frame.size.height
        
        let mySession: AVCaptureSession = AVCaptureSession() //セッションの作成
        var cd_captureDevice: AVCaptureDevice! // デバイス
        let io_imageOutput: AVCaptureStillImageOutput = AVCaptureStillImageOutput() //出力先の生成
        let devices = AVCaptureDevice.devices() //デバイスの一覧
        let audioCaptureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo) //マイクの取得
        
        var ai_audioInput = AVCaptureDeviceInput()
        do {
            ai_audioInput = try AVCaptureDeviceInput(device: audioCaptureDevice) //マイクをセッションのInputに追加
        } catch let error as NSError {
            print(error)
        }

        // バックライトをcd_captureDeviceに格納
        for device in devices{
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if (device.position == AVCaptureDevicePosition.Back){
                    cd_captureDevice = device as! AVCaptureDevice
                }
            }
        }

        var vi_videoInput = AVCaptureDeviceInput()
        do {
            vi_videoInput = try AVCaptureDeviceInput.init(device: cd_captureDevice) // バックカメラの取得
        } catch {
            print(error)
        }
        
        if mySession.canAddInput(ai_audioInput){
            mySession.addInput(ai_audioInput) //オーディオをセッションのInputに追加
        }
        if mySession.canAddInput(vi_videoInput) {
            mySession.addInput(vi_videoInput) //ビデオをセッションのInputに追加
        }
        
        mySession.addOutput(io_imageOutput)//セッションに追加
        vo_videoOutput = AVCaptureMovieFileOutput() //動画の保存
        mySession.addOutput(vo_videoOutput) //ビデオ出力をOutputに追加

        //画像を表示するレイヤーに追加
        let vl_videoLayer = AVCaptureVideoPreviewLayer(session: mySession)
        vl_videoLayer.frame = self.view.bounds
        vl_videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        
        self.view.layer.addSublayer(vl_videoLayer) // Viewに追加
        
        mySession.startRunning() //セッション開始

        // スタートボタンを作成
        sb_startButton.frame = CGRectMake(0, 0, 50, 50)
        sb_startButton.backgroundColor = UIColor.redColor()
        sb_startButton.setTitle("開始", forState: .Normal)
        sb_startButton.layer.masksToBounds = true
        sb_startButton.layer.cornerRadius = 20
        sb_startButton.layer.position = CGPointMake(sw_screenWidth/4, sh_screenHeight-50)
        sb_startButton.addTarget(self, action: "onClickButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(sb_startButton)
        // ストップボタン作成
        sb_stopButton.frame = CGRectMake(0, 0, 50, 50)
        sb_stopButton.backgroundColor = UIColor.blackColor()
        sb_stopButton.setTitle("停止", forState: .Normal)
        sb_stopButton.layer.masksToBounds = true
        sb_stopButton.layer.cornerRadius = 20
        sb_stopButton.layer.position = CGPointMake(sw_screenWidth*3/4, sh_screenHeight-50)
        sb_stopButton.addTarget(self, action: "onClickButton:", forControlEvents: .TouchUpInside)
        self.view.addSubview(sb_stopButton)
     
        
    }
    
    //　ボタンイべント
    internal func onClickButton(sender: UIButton) {
        // 撮影開始
        if (sender == sb_startButton) {            
            let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
            
            let documentsDirectory = paths[0] // フォルダ.
            let filePath : String? = "\(documentsDirectory)/test.mp4" // ファイル名.
            let fileURL : NSURL = NSURL(fileURLWithPath: filePath!) // URL.
            
            vo_videoOutput.startRecordingToOutputFileURL(fileURL, recordingDelegate: self) // 録画開始
        } else if (sender == sb_stopButton) {
            vo_videoOutput.stopRecording()
        }
    }
    
    // 動画がキャプチャーされた後に呼ばれるメソッド.
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        print("キャプチャー終了:didFinishRecordingToOutputFileAtURL")
        
        let assetsLib = ALAssetsLibrary()
        assetsLib.writeVideoAtPathToSavedPhotosAlbum(outputFileURL, completionBlock: nil)
    }
    
    // 動画のキャプチャーが開始された時に呼ばれるメソッド.
    func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
        print("キャプチャー開始:didStartRecordingToOutputFileAtURL")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

