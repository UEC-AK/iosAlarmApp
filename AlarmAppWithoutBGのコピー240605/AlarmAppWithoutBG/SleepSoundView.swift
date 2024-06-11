
//  SleepSoundView.swift
//  AlarmUI
//
//  Created by 小松野蒼 on 2023/11/16.
//

import SwiftUI
import AVKit

struct SleepSoundView: View {
    
    @EnvironmentObject private var appState: AppState
    @ObservedObject var audioManager: AudioPlayerManager // AudioPlayerManagerをObservedObjectとして受け取る
    
    let audioFileNames = ["Alarm1", "Alarm2"]
    
    var body: some View {
        VStack {
            List(audioFileNames, id: \.self) { fileName in
                HStack {
                    Button(action: {
                        // 選択された音声ファイルを更新
                        self.appState.selectedSleepAudioFileName = fileName
                    }) {
                        Text(fileName)
                    }
                    
                    Spacer() // チェックマークとの間にスペーサー
                    
                    if self.appState.selectedSleepAudioFileName == fileName {
                        Image(systemName: "checkmark") // チェックマーク
                    }
                    
                    // 再生中の音声ファイルに基づいて、再生ボタンまたは停止ボタンを表示
                    if audioManager.currentlyPlaying == fileName {
                        Button(action: {
                            self.audioManager.stopPlaying()
                        }) {
                            Image(systemName: "stop.fill")
                        }
                    } else {
                        Button(action: {
                            self.audioManager.startPlaying(fileName: fileName)
                        }) {
                            Image(systemName: "play.fill")
                        }
                    }
                    
                }
            }
            
        }
        .navigationBarTitle("睡眠導入音選択", displayMode: .inline)
    }
    
}

struct SleepSoundView_Previews: PreviewProvider {
    static var previews: some View {
        SleepSoundView(audioManager: AudioPlayerManager())
            .environmentObject(AppState()) // AppStateオブジェクトを提供
    }
}


