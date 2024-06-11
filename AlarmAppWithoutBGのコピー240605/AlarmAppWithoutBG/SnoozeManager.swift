//
//  SnoozeManager.swift
//  AlarmAppWithoutBG
//
//  Created by 小松野蒼 on 2023/12/08.
//

//  SnoozeManager.swift
//  test231204
//
//  Created by 小松野蒼 on 2023/12/04.
//
import SwiftUI
import AVFoundation
import Foundation
import UserNotifications

class SnoozeManager {
    var appState: AppState
    var audioManager: AudioManager
    
    init(appState: AppState) {
        self.appState = appState
        self.audioManager = AudioManager(appState: appState)
    }
    
    func setAlarmSnooze() {
        // スヌーズを設定する
        appState.isAlarmSet = true
        appState.isSnoozeSet = true
        startCountdown()
    }
    
//スヌーズに移行する時のアラームのストップの関数
    func stopAlarmSnooze() {
        
        appState.isAlarmActive = false
        
        //playerをif文に入れない工夫が必要------------//
        
        if let player = self.appState.player1, !player.isPlaying {
            // ボタンアクションで音量調整を有効にする
            appState.isVolumeControlEnabled = true
            // DispatchQueueを使用して、0.1秒後に以下の処理を実行
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                //システムボリュームの値を一時保存
                self.appState.temporaryValue = AVAudioSession.sharedInstance().outputVolume
                print("音量一時保存:\(self.appState.temporaryValue)")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                // ボタンアクションで音量調整を無効にする
                self.appState.isVolumeControlEnabled = false
            }
        }
        
        // タイマーを無効化し、nilに設定
        appState.fadeInTimer?.invalidate()
        appState.fadeInTimer = nil
        // タイマーを無効化し、nilに設定
        appState.fadeOutTimer?.invalidate()
        appState.fadeOutTimer = nil
        
        //タイマー無効化
        appState.SleepSoundStopTimer?.invalidate()
        appState.SleepSoundStopTimer = nil
        
        // ボタンアクションで音量調整を有効にする
        appState.isVolumeControlEnabled = true
        // DispatchQueueを使用して、0.1秒後に以下の処理を実行
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            //システムボリュームを元に戻す
            self.appState.customSliderValue = self.appState.temporaryValue
            self.appState.systemVolume = self.appState.temporaryValue
            print("戻した音量: \(self.appState.temporaryValue)")
            print("customslider: \(self.appState.customSliderValue)")
            print("systemvolume: \(self.appState.systemVolume)")
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // ボタンアクションで音量調整を無効にする
            self.appState.isVolumeControlEnabled = false
        }
        
        // アラームを停止する
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        //    self.appState.isAlarmSet = false
        }
        
        // スヌーズを停止する
        appState.player1?.stop()
        appState.vibrationManager.stopVibration()
        // ローカル通知の解除
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["alarmNotification"])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["alarmNotification"])
    }
    
    func startCountdown() {
        // カウントダウンを開始する
        appState.timer?.invalidate()
        appState.countdown = appState.minutesOptions[appState.selectedMinutesIndex] * 60
        
        appState.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak appState] _ in
            guard let appState = appState else { return }
            
            if appState.countdown > 0 {
                appState.countdown -= 1
            } else {
                appState.timer?.invalidate()
                // カウントダウン終了時の処理を追加
                let notificationManager = NotificationManager(appState: appState)
                notificationManager.scheduleSnoozeNotification()
                
                // タイマーを無効化し、nilに設定
                appState.fadeOutTimer?.invalidate()
                appState.fadeOutTimer = nil
                
                appState.isAlarmActive = true
                
                
                //appState.isVibrationEnabledじゃないなら流さない
                if appState.isVibrationEnabled {
                    appState.vibrationManager.startVibration()
                }
                //-----------------------------------------
                
                //appState.isAlarmEnabledじゃないなら流さない
                let audioManager = AudioManager(appState: appState)
                if appState.isAlarmEnabled {
                    audioManager.playAlarmSound()
                }
                //---------------------------------------
                
                appState.isSnoozeSet = false
            }
        }
    }
    
    func resetCountdown() {
        // カウントダウンをリセットする
        appState.countdown = appState.minutesOptions[appState.selectedMinutesIndex] * 60
        appState.timer?.invalidate()
    }
}



