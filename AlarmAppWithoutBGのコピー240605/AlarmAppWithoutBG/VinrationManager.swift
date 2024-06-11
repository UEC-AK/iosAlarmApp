//
//  VinrationManager.swift
//  AlarmAppWithoutBG
//
//  Created by 小松野蒼 on 2023/12/08.
//
//
//  VibrationManager.swift
//  test231204
//
//  Created by 小松野蒼 on 2023/12/04.
//

import AudioToolbox

class VibrationManager {
    var isVibrating: Bool = false
    var vibrationTimer: Timer?

    // バイブレーションを開始
    func startVibration() {
        if !isVibrating {
            print("startVibe")
            isVibrating = true
            vibrationTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                // バイブレーションを再生
                AudioServicesPlayAlertSoundWithCompletion(SystemSoundID(kSystemSoundID_Vibrate)) {
                    // バイブレーション再生完了時の処理
                }
            }
        }
    }

    // バイブレーションを停止
    func stopVibration() {
        print("stopVibe")
        isVibrating = false
        vibrationTimer?.invalidate()
        vibrationTimer = nil
    }
}



