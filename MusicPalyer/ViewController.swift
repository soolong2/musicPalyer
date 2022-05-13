//
//  ViewController.swift
//  MusicPalyer
//
//  Created by so on 2022/05/10.
//

import UIKit
import AVFoundation


class ViewController: UIViewController, AVAudioPlayerDelegate {
    
    var player: AVAudioPlayer!
    var timer: Timer!
    
    
    @IBOutlet weak var PlayPauseButton: UIButton!
    
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var progressSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        self.addViewsWithCode()
        self.initializePlayer()
    }
    
    
    func initializePlayer(){
        guard let soundAsset = NSDataAsset(name: "sound") else {
            print("음원 파일 에셋을 가져올수없다.")
            return
        }
        do{
            try self.player = AVAudioPlayer(data: soundAsset.data)
            self.player.delegate = self
        }catch let error as NSError{
            print("플레이어 초기화 실패")
            print("코드 : \(error.code), 메세지\(error.localizedDescription)")
        }
        self.progressSlider.maximumValue = Float(self.player.duration)
        self.progressSlider.minimumValue = 0
        self.progressSlider.value = Float(self.player.currentTime)
    }
    func updateTimeLabelText(time: TimeInterval){
        let minute: Int = Int(time / 60)
        let second: Int = Int(time.truncatingRemainder(dividingBy: 60))
        let milisecond: Int = Int(time.truncatingRemainder(dividingBy: 1) * 100)
        
        let timeText: String = String(format: "%02ld:%02ld:%02ld",minute, second, milisecond )
        self.timeLabel.text = timeText
    }
    func makeAndFireTimer() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { [unowned self]
            (timer: Timer) in
            
            if self.progressSlider.isTracking {return}
            
            self.updateTimeLabelText(time: self.player.currentTime)
            self.progressSlider.value = Float(self.player.currentTime)
        })
        self.timer.fire()
    }
    //타이머해제 매소드
    func invalidateTimer() {
        self.timer.invalidate()
        self.timer = nil
    }
    
    // MARK: 액션
    @IBAction func playButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected{
            self.player?.play()
        } else{
            self.player?.pause()
        }
        
        if sender.isSelected{
            self.makeAndFireTimer()
        } else{
            self.invalidateTimer()
        }
        
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        self.updateTimeLabelText(time: TimeInterval(sender.value))
        if sender.isTracking {return}
        self.player.currentTime = TimeInterval(sender.value)
        
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        guard let error: Error = error else {
            print("오디오 디코드 오류")
            return
        }
        let message: String
        message = "오디오 플레이어 오류 \(error.localizedDescription)"
        
        let alert: UIAlertController = UIAlertController(title: "알림", message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction: UIAlertAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){
            (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.PlayPauseButton.isSelected = false
        self.progressSlider.value = 0
        self.updateTimeLabelText(time: 0)
        self.invalidateTimer()
    }
    
}

