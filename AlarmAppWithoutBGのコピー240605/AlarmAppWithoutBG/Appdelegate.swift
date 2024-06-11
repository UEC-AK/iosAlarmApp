//
//  Appdelegate.swift
//  AlarmAppWithoutBG
//
//  Created by 小松野蒼 on 2023/12/08.
//

//
//  AppDelegate.swift
//  test231204
//
//  Created by 小松野蒼 on 2023/12/04.
//

import SwiftUI
import UserNotifications
import AVFoundation

class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    var appState: AppState?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 通知センターの通知を受け取るリスナーを登録
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(.playback, mode: .default)
            }
            catch let e {
                print(e.localizedDescription)
            }
        
        // UNUserNotificationCenterのdelegateを設定
        UNUserNotificationCenter.current().delegate = self
        
        // 通知の許可状態を確認
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized:
                // 通知が許可されている場合の処理
                print("通知は許可されています")
            case .denied:
                // 通知が拒否されている場合の処理
                print("通知は拒否されています")
                self.showNotificationSettingsAlert()
            case .notDetermined:
                // 通知の許可状態が不明の場合、リクエストを行う
                self.requestNotificationPermission()
            default:
                break
            }
        }
        
        return true
    }
    
    @objc func appDidEnterBackground() {
        print("アプリがバックグラウンドに移行しました")
        guard let appState = appState else { return }
        if appState.isAlarmSet {
            let audioManager = AudioManager(appState: appState)
            audioManager.playSound3()
            
            let alarmManager = AlarmManager(appState: appState)
            alarmManager.check()
        }
    }
    
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                // 通知が許可された場合の処理
                print("通知が許可されました")
            } else if let error = error {
                // エラーが発生した場合の処理
                print("通知の許可リクエストエラー: \(error.localizedDescription)")
            }
        }
    }
    
    // アラートを表示するメソッド
    func showNotificationSettingsAlert() {
        
        DispatchQueue.main.async {
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                if UIApplication.shared.canOpenURL(settingsURL) {
                    let alert = UIAlertController(
                        title: "通知が拒否されています",
                        message: "通知を許可するには、設定画面で通知を有効にしてください。",
                        preferredStyle: .alert
                    )
                    
                    let cancelAction = UIAlertAction(title: "キャンセル", style: .default, handler: nil)
                    let openSettingsAction = UIAlertAction(title: "設定を開く", style: .default) { _ in
                        UIApplication.shared.open(settingsURL)
                    }
                    
                    alert.addAction(cancelAction)
                    alert.addAction(openSettingsAction)
                    
                    if let windowScene = UIApplication.shared.connectedScenes
                        .first(where: { $0 is UIWindowScene }) as? UIWindowScene,
                       let rootViewController = windowScene.windows.first?.rootViewController {
                        rootViewController.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    // その他のUNUserNotificationCenterDelegateメソッドやアプリの処理を追加
}
