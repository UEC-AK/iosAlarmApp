//
//  AppState.swift
//  AlarmAppWithoutBG
//
//  Created by 小松野蒼 on 2023/12/08.
//

//
//  AppState.swift
//  AlarmUI
//
//  Created by 小松野蒼 on 2023/12/05.
//

import SwiftUI
import AVFoundation

class AppState: ObservableObject {
    
    //アラームがアクティブの時の宣言
    @Published var isAlarmActive = false
    
    //機能のオンオフ
    @AppStorage("isAlarmEnabled") var isAlarmEnabled = true
    @AppStorage("isVibrationEnabled") var isVibrationEnabled = true
    @AppStorage("isSnoozeEnabled") var isSnoozeEnabled = true
    @AppStorage("isSleepSoundEnabled") var isSleepSoundEnabled = true
    @AppStorage("isFadeInEnabled") var isFadeInEnabled = true
    @AppStorage("isSpeaker") var isSpeakerEnabled = false
    
    //睡眠導入音楽の再生時間
    @AppStorage("selectedDurationIndex") var selectedDurationIndex = 0
    let durationOptions = [1, 5, 10, 15, 30, 60, 120]
    
    //睡眠導入音楽の音声ファイル
    @AppStorage("selectedSleepAudioFileName") var selectedSleepAudioFileName = "Alarm1"
    //睡眠導入音楽のボリューム
    @AppStorage("sleepAudioVolume") var sleepAudioVolume: Double = 1
    //アラーム音の調整用スライダー
    @AppStorage("additionalSliderValue") var additionalSliderValue: Double = 1
    //アラーム音の音声ファイル
    @AppStorage("selectedAudioFileName") var selectedAudioFileName = "Alarm1"
    
    // AVAudioPlayer インスタンス
    @Published var player1: AVAudioPlayer?
    @Published var player2: AVAudioPlayer?
    @Published var player3: AVAudioPlayer?
    
    //イヤホンが取れた時に止める。
    
    init() {
        // ヘッドフォンの抜き差しを監視する通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange), name: AVAudioSession.routeChangeNotification, object: nil)
    }

    @objc func handleRouteChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonValue) else {
            return
        }

        switch reason {
        case .oldDeviceUnavailable:
            // ヘッドフォンが取り外された場合
            if player1?.isPlaying == true {
                player1?.stop()
            }
            if player2?.isPlaying == true {
                player2?.stop()
            }
            
        default:
            break
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    //選択された時刻
    @Published var selectedDate = Date()
    
    @Published var systemVolume: Float = AVAudioSession.sharedInstance().outputVolume
    @Published var customSliderValue: Float = AVAudioSession.sharedInstance().outputVolume
    
    // 音量調整の有効/無効を管理するプロパティ
    @Published var isVolumeControlEnabled: Bool = false
    
    @Published var isPlaying: Bool = false // Start/Stop ボタンの状態

    @Published var temporaryValue: Float = AVAudioSession.sharedInstance().outputVolume
    
    @Published var SleepSoundStopTimer: Timer?
    @Published var fadeInTimer: Timer?
    @Published var fadeOutTimer: Timer?
    
    
    //test231204のコード
    @Published var selectedTime = Date()
    @Published var isAlarmSet = false
    @Published var isSnoozeSet = false
    
    @Published var currentTimeString = ""
    @Published var buttonText = "Start"
    
    @Published var isVibrating = false
    let vibrationManager = VibrationManager()
    
    @Published var countdown: Int = 60 // カウントダウンの初期値（秒）
    @Published var timer: Timer?
    @AppStorage("selectedMinutesIndex") var selectedMinutesIndex: Int = 0
    let minutesOptions = [1, 5, 10, 15]
}
