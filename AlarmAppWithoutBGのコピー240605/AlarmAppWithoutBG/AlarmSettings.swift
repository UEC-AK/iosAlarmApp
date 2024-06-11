//
//  Alarm.swift
//  AlarmAppWithoutBG
//
//  Created by 小松野蒼 on 2023/12/08.
//
//  AlarmSettings.swift
//  AlarmUI
//
//  Created by 小松野蒼 on 2023/11/16.
//

import SwiftUI
import MediaPlayer
import AVKit


class AudioPlayerManager: NSObject, ObservableObject, AVAudioPlayerDelegate {
    var audioPlayer: AVAudioPlayer?
    @Published var currentlyPlaying: String? = nil
    
    func startPlaying(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "wav") else { return }
        do {
            stopPlaying() // 新しいトラックを再生する前に、前のトラックを停止
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            audioPlayer?.play()
            currentlyPlaying = fileName
        } catch {
            print("音声ファイルの再生に失敗しました。", error)
        }
    }
    
    func stopPlaying() {
        audioPlayer?.stop()
        audioPlayer = nil
        currentlyPlaying = nil
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            DispatchQueue.main.async {
                self.currentlyPlaying = nil
            }
        }
    }
}

struct AlarmSettings: View {
    
    @EnvironmentObject var viewModel: ImagePickerViewModel
    
    @EnvironmentObject private var appState: AppState
    @StateObject private var audioManager = AudioPlayerManager()
    //ピッカーの開閉
    @State private var isPickerVisibleSnooze = true
    
    //いらない関数
    @State private var isSoundViewPresented = false
    @State private var isSleepSoundViewPresented = false
    @State private var isReviewPresented = false
    @State private var isBgSettingPresented = false

    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("アラーム設定")) {
                    
                    Toggle("アラーム音", isOn: $appState.isAlarmEnabled)
                    
                    NavigationLink("アラーム音選択", destination: SoundView(audioManager: audioManager))
                    
                    Toggle("バイブレーション", isOn: $appState.isVibrationEnabled)
                    
                    VStack {
                        HStack {
                            Image(systemName: "speaker.fill")
                            
                            // 追加のスライダーとテキスト
                            Slider(value: $appState.additionalSliderValue, in: 0...1, step: 0.01)
                                .frame(width: 250, height: 10)
                            
                            Image(systemName: "speaker.2.fill")
                        }
                        .padding(.top)
                        
                        Text("アラームの音量:\(Int(appState.additionalSliderValue * 100))%")
                            .foregroundColor(.black)
                            .font(.system(size: 12))
                    }
                    
                    Toggle("フェードイン", isOn: $appState.isFadeInEnabled)
                    
                    HStack {
                        
                        Text("スヌーズ")
                        
                        Spacer()
                        
                        if appState.isSnoozeEnabled {
                            
                            Picker("Select Minutes", selection: $appState.selectedMinutesIndex) {
                                ForEach(appState.minutesOptions.indices, id: \.self) { index in
                                    Text("\(self.appState.minutesOptions[index]) 分")
                                        .tag(index)
                                }
                            }
                            .labelsHidden() // ラベルを非表示にする（必要に応じて変更）
                            .frame(alignment: .trailing)
                            
                        }
                        Toggle("", isOn: $appState.isSnoozeEnabled)
                    }
                }
                
                Section(header: Text("睡眠導入音楽")) {
                    
                    Toggle("睡眠導入音", isOn: $appState.isSleepSoundEnabled)
                    
                    NavigationLink("睡眠導入音楽の選択", destination: SleepSoundView(audioManager: audioManager))
                    
                    VStack {
                            HStack {
                                
                                Image(systemName: "speaker.fill") // スピーカー最小アイコン
                                Slider(value: $appState.sleepAudioVolume, in: 0...1, step: 0.01)
                                Image(systemName: "speaker.3.fill") // スピーカー最大アイコン
                            }
                        Text("Volume: \(Int(appState.sleepAudioVolume * 100))%")
                    }
                    
                    HStack {
                        Text("睡眠導入音の再生時間")
                        
                        Spacer()
                        
                        Picker(selection: $appState.selectedDurationIndex, label: Text("再生時間")) {
                            ForEach(appState.durationOptions.indices, id: \.self) { index in
                                Text("\(appState.durationOptions[index]) 分")
                            }
                        }
                        .labelsHidden() // ラベルを非表示にする（必要に応じて変更）
                    }
                    
                }
                
                Section(header: Text("オーディオデバイス未接続時")) {
                    Toggle("スピーカーで再生", isOn: $appState.isSpeakerEnabled)
                }
                
                Section(header: Text("")) {
                    NavigationLink("背景画像の選択", destination: BgSettingView())
                }
                
                Section(header: Text("")) {
                    NavigationLink("このAppについて", destination: AboutAppView())
                }
                
            }
            .navigationTitle("設定")
        }
    }
}

//もう必要ないコード
struct AlarmSelectView: View {
    
    @EnvironmentObject private var appState: AppState
    
    let audioFileNames = ["Alarm1", "Alarm2"]
    
    var body: some View {
        
        NavigationStack {
            List(audioFileNames, id: \.self) { fileName in
                HStack {
                    Button(action: {
                        // 選択された音声ファイルを更新
                        self.appState.selectedAudioFileName = fileName
                    }) {
                        Text(fileName)
                    }
                    
                    Spacer() // チェックマークとの間にスペーサー
                    
                    if self.appState.selectedAudioFileName == fileName {
                        Image(systemName: "checkmark") // チェックマーク
                    }
                }
            }
            .navigationTitle("アラーム音選択")
        }
    }
}

struct SleepSoundSelectView: View {
    
    @EnvironmentObject private var appState: AppState
    
    let audioFileNames = ["Alarm1", "Alarm2"]
    
    var body: some View {
        NavigationStack {
            
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
                }
            }
            .navigationTitle("睡眠導入音選択")
        }
    }
}

struct AboutAppView: View {
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Rise")) {
                    Text("Rise")
                }
                
                Section(header: Text("")) {
                    
                    Text("Riseをお勧めする")
                    Text("レビューを書く")
                    Text("ご意見・ご感想を送信する")
                }
                Section(header: Text("")) {
                    Text("KOMATSUNOBROS.comにアクセス")
                }
            }
            .navigationTitle("このAppについて")
        }
    }
}


#Preview {
    AlarmSettings()
        .environmentObject(AppState()) // AppStateオブジェクトを提供
        .environmentObject(ImagePickerViewModel())
}
