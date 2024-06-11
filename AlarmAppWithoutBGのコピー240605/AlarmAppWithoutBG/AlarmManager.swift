//
//  AlarmManager.swift
//  AlarmAppWithoutBG
//
//  Created by 小松野蒼 on 2023/12/08.
//

//
//  AlarmManager.swift
//  test231204
//
//  Created by 小松野蒼 on 2023/12/04.
//

import Foundation
import SwiftUI
import AVFoundation
import UserNotifications
import MediaPlayer

class AlarmManager {
    var appState: AppState
    var notificationManager: NotificationManager
    var audioManager: AudioManager
    
    init(appState: AppState) {
        self.appState = appState
        self.notificationManager = NotificationManager(appState: appState)
        self.audioManager = AudioManager(appState: appState)
    }
    
    func setAlarm() {
        
        // アラームを設定する
        appState.isAlarmSet = true
        appState.buttonText = "Stop"
        checkAlarm()
        
        
        notificationManager.scheduleAlarmNotification()
        
        //isSleepSoundEnabledなら再生----------------------------------------------
        if appState.isSleepSoundEnabled {
            //睡眠導入音楽再生
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.audioManager.playSleepSound()
       //         print("selectedDuration: \(selectedDuration)")
       //         print("selectedDurationIndex: \(self.appState.selectedDurationIndex)")
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                let selectedDuration = self.appState.durationOptions[self.appState.selectedDurationIndex]
                
                self.appState.SleepSoundStopTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(selectedDuration) * 60, repeats: false) { [self] _ in
                    audioManager.startFadeOutTimer()
                }
            }
        }
        //-------------------------------------------------------------------------
    }
    
    func stopAlarm() {
        
        appState.isAlarmActive = false
        
        //playerをif文に入れない工夫が必要-----------//
        
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
            self.appState.isAlarmSet = false
            self.appState.isSnoozeSet = false
        }
        appState.player1?.stop()
        appState.player2?.stop()
        appState.buttonText = "Start"
        appState.selectedTime = Date()
        appState.vibrationManager.stopVibration()
        
        let snoozeManager = SnoozeManager(appState: appState)
        snoozeManager.resetCountdown()
        
        
        // ローカル通知の解除
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["alarmNotification"])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: ["alarmNotification"])
    }
    
    func check() {
        // アラームの状態を確認する
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkAlarm()
        }
        // タイマーをランループに追加
        RunLoop.current.add(timer, forMode: .common)
    }
    
    func checkAlarm() {
        // アラームの状態を確認する
        //playerをif文に入れない工夫が必要-----------//
        
        if appState.isAlarmSet && !appState.isSnoozeSet && !appState.isAlarmActive {
            let calendar = Calendar.current
            let currentComponents = calendar.dateComponents([.hour, .minute, .second], from: Date())
                   let selectedComponents = calendar.dateComponents([.hour, .minute, .second], from: appState.selectedTime)
            
            if currentComponents.hour == selectedComponents.hour && currentComponents.minute == selectedComponents.minute && currentComponents.second == 0 {
                
                //後でaudiomanagerのalarmsoundに戻す可能性あり
                do {
                    try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                    try AVAudioSession.sharedInstance().setActive(true)
                } catch {
                    print("Failed to set audio session category. Error: \(error)")
                }
                
                //-----------------------------------------
                
                // タイマーを無効化し、nilに設定
                appState.fadeOutTimer?.invalidate()
                appState.fadeOutTimer = nil
                
                //タイマー無効化
                appState.SleepSoundStopTimer?.invalidate()
                appState.SleepSoundStopTimer = nil
                
                appState.isAlarmActive = true
                
                //appState.isAlarmEnabledじゃないなら実行しない
                if appState.isAlarmEnabled {
                    audioManager.playAlarmSound()
                }
                //-----------------------------------------
                
                //appState.isVibrationEnabledじゃないなら実行しない
                if appState.isVibrationEnabled {
                    appState.vibrationManager.startVibration()
                }
                //-----------------------------------------
                
            } else {
                return
            }
        }
    }
}


