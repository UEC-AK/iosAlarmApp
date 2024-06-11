//
//  AudioManager.swift
//  test231204
//
//  Created by 小松野蒼 on 2023/12/04.
//

import AVFoundation

class AudioManager {
    var appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func playAlarmSound() {
        // アラーム音を再生する
        if appState.player2?.isPlaying == true {
            appState.player2?.stop()
            print("player2 is stop")
        }
        
        guard let path = Bundle.main.path(forResource: appState.selectedAudioFileName, ofType: "wav") else {
            print("音声ファイルが見つかりません")
            return
        }
        
        do {
            
            // ボタンアクションで音量調整を有効にする
            appState.isVolumeControlEnabled = true
            // DispatchQueueを使用して、0.1秒後に以下の処理を実行
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                //システムボリュームの値を一時保存
                self.appState.temporaryValue = self.appState.customSliderValue
                print("音量一時保存:\(self.appState.temporaryValue)")
                // additionalSliderValueの値をcustomSliderValueに反映
                self.appState.customSliderValue = Float(self.appState.additionalSliderValue)
                print("音量custom:\(self.appState.customSliderValue)")
                // additionalSliderValueの値をsystemVolumeにも反映
                self.appState.systemVolume = Float(self.appState.additionalSliderValue)
                print("音量system:\(self.appState.systemVolume)")
                print("音量:\(AVAudioSession.sharedInstance().outputVolume)")
                
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                // ボタンアクションで音量調整を無効にする
                self.appState.isVolumeControlEnabled = false
            }
            
            // AVAudioPlayer インスタンスを作成
            self.appState.player1 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            
            self.appState.player1?.prepareToPlay()
            // ループ再生設定
            self.appState.player1?.numberOfLoops = -1
            
            // 音量を設定
            self.appState.player1?.volume = appState.isFadeInEnabled ? 0.01 : 1.0
            
            // 再生
            self.appState.player1?.play()
            
            print("アラーム再生中")
            if appState.isFadeInEnabled {
                startFadeTimer()
            }
            
        } catch {
            print("音声の再生に失敗しました: \(error)")
        }
    }
    
    
    func playSleepSound() {
        guard let path = Bundle.main.path(forResource: appState.selectedSleepAudioFileName, ofType: "wav") else {
            print("音声ファイルが見つかりません")
            return
        }
        
        let volume = Float(self.appState.sleepAudioVolume)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)

            // AVAudioPlayer インスタンスを作成
            self.appState.player2 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            self.appState.player2?.volume = volume
            self.appState.player2?.numberOfLoops = -1

            // 再生
            self.appState.player2?.play()
            
           // appState.SleepSoundStopTimer = Timer.scheduledTimer(withTimeInterval: durationMinutes * 60, repeats: false) { [self] _ in
       //         startFadeOutTimer()
        //    }
            
            print("playSleepSoundが実行されました")

        } catch {
            print("音声の再生に失敗しました: \(error)")
        }
    }
    
    
    func playSound3() {
        
        guard let path = Bundle.main.path(forResource: "silent", ofType: "wav") else {
            print("音声ファイルが見つかりません")
            return
        }
        
        do {
            
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: .mixWithOthers)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // AVAudioPlayer インスタンスを作成
            self.appState.player3 = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            
            // ループ再生設定
            self.appState.player3?.numberOfLoops = -1
            
            // 再生
            self.appState.player3?.play()
            
            print("playSound3が実行されました")
            
        } catch {
            print("音声の再生に失敗しました: \(error)")
        }
    }
    // 音量情報を引数として追加
    
    func startFadeTimer() {
        appState.fadeInTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] _ in
           
            if let player = appState.player1 {
                if player.volume < 0.99 {
                    player.volume += 0.01
                    print("fadeIn:\(player.volume)")
                } else {
                    player.volume = 1.0
                    print("fadeIn:\(player.volume)")
                    appState.fadeInTimer?.invalidate()
                    appState.fadeInTimer = nil
                }
                
            }
        }
    }
    
    func startFadeOutTimer() {
        appState.fadeOutTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [self] _ in
            
            if let player = appState.player2 {
                if player.volume > 0.01 {  // player.volumeが0.01より大きい場合のみ、減少させる
                    player.volume -= 0.01
                    print("fadeOut:\(player.volume)")
                } else { // player.volumeを直接0に設定
                    player.volume = 0
                    print("fadeOut:\(player.volume)")
                    appState.fadeOutTimer?.invalidate()
                    appState.fadeOutTimer = nil
                }
            }
            
        }
    }
    
    func volumeManager() {
        // ボタンアクションで音量調整を有効にする
        appState.isVolumeControlEnabled = true
        // DispatchQueueを使用して、0.1秒後に以下の処理を実行
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            //システムボリュームの値を一時保存
            self.appState.temporaryValue = self.appState.customSliderValue
            print("音量一時保存:\(self.appState.temporaryValue)")
            // additionalSliderValueの値をcustomSliderValueに反映
            self.appState.customSliderValue = Float(self.appState.additionalSliderValue)
            print("音量custom:\(self.appState.customSliderValue)")
            // additionalSliderValueの値をsystemVolumeにも反映
            self.appState.systemVolume = Float(self.appState.additionalSliderValue)
            print("音量system:\(self.appState.systemVolume)")
            print("音量:\(AVAudioSession.sharedInstance().outputVolume)")
            
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            // ボタンアクションで音量調整を無効にする
            self.appState.isVolumeControlEnabled = false
        }
    }
}


