
//
//  Selectsound.swift
//  AlarmUI
//
//  Created by 小松野蒼 on 2023/11/16.
//

import SwiftUI
import AVKit

struct SoundView: View {
    @EnvironmentObject private var appState: AppState
    @ObservedObject var audioManager: AudioPlayerManager // AudioPlayerManagerをObservedObjectとして受け取る
    let audioFileNames = ["Alarm1", "Alarm2"]
    
    var body: some View {
        VStack {
            List(audioFileNames, id: \.self) { fileName in
                HStack {
                    Button(action: {
                        // 選択された音声ファイルを更新
                        self.appState.selectedAudioFileName = fileName
                    }) {
                        Text(fileName)
                    }
                    
                    Spacer()
                    
                    if self.appState.selectedAudioFileName == fileName {
                        Image(systemName: "checkmark") // 選択されている音声ファイルにチェックマークを表示
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
        .navigationBarTitle("アラーム音選択", displayMode: .inline)
    }
}


struct SoundView_Previews: PreviewProvider {
    static var previews: some View {
        SoundView(audioManager: AudioPlayerManager()).environmentObject(AppState())
    }
}
