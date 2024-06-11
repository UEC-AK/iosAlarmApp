//
//  ContentView.swift
//  AlarmAppWithoutBG
//
//  Created by 小松野蒼 on 2023/12/08.
//

//
//  ContentView.swift
//  AlarmUI
//
//  Created by 小松野蒼 on 2023/11/15.
//

import SwiftUI
import AVKit
import AVFoundation
import UserNotifications
import MediaPlayer

struct ContentView: View {
    
    @EnvironmentObject var viewModel: ImagePickerViewModel
    
    @EnvironmentObject private var appState: AppState
    @Environment(\.scenePhase) private var scenePhase
    //設定画面を開く
    @State private var isSettingPresented = false
    
    //背景画像の値
    @State private var selectedImage: UIImage?
    
    @State private var opacity = 0.0
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                
                Color.black.opacity(0.9)
                    .edgesIgnoringSafeArea(.all)
                
                if let image = viewModel.selectedImage {
                    // 画像が選択されている場合、背景として表示
                    Image(uiImage: image)
                        .resizable()  // 画像をリサイズ可能に
                        .aspectRatio(contentMode: .fill)  // コンテンツモードをfillに設定
                        .edgesIgnoringSafeArea(.all)  // Safe Areaを無視して画面全体に表示
                } else {
                    // 画像を表示するビューを作成
                    Image("21") // "backgroundImage"は画像ファイルの名前です
                        .resizable() // 画像のリサイズを許可
                        .scaledToFill() // 画像をビューに合わせて拡大縮小
                        .edgesIgnoringSafeArea(.all) // セーフエリア外まで画像を拡張
                        .opacity(0.9) // 0から1の間の値を設定
                }
                
                VStack {
                    
                    NavigationLink(destination: AlarmSettings()) {
                        Text("Set")
                            .frame(width: 70, height: 70)
                    }
                    .buttonStyle(GlassmorphismButtonStyle.glassmorphism)
                    
                    Text("Time") // 追加
                        .foregroundColor(.black)
                        .padding(.top, 20) // 必要に応じて調整
                    
                    Text(appState.currentTimeString)
                        .font(Font.custom("Morro-Regular", size: 50))
                        .onTapGesture {
                            appState.selectedTime = Date()
                            // ここに処理を追加（必要に応じて）
                        }
                    
                    Image(systemName: "headphones")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(isHeadphonesConnected() ? .black : .red)
                        .overlay(
                            isHeadphonesConnected() ? nil : AnyView(
                                Image(systemName: "slash.circle")
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .foregroundColor(.red)
                            )
                        )
                    
                    if appState.isAlarmSet && appState.isSnoozeSet {
                        
                        Text("スヌーズ中")
                            .foregroundColor(.red) // 新しいテキストのスタイル
                            .padding(.top, 20) // 必要に応じて調整
                        
                        Text("Countdown: \(formatTime(appState.countdown))")
                            .foregroundColor(.red)
                            .font(.largeTitle)
                    }
                    
                    if appState.isAlarmSet && !appState.isSnoozeSet {
                        
                        Text("起きる時間")
                            .foregroundColor(.black) // 新しいテキストのスタイル
                            .padding(.top, 20) // 必要に応じて調整
                        
                        Text(selectedTimeString) // 新しいテキストで選択した時刻を表示
                            .font(Font.custom("Morro-Regular", size: 50))
                        
                    } else if !appState.isAlarmSet {
                        
                        ZStack {
                            // 背景としてultraThinMaterialを使用
                            Text("")
                                .frame(width: 300, height: 175)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                                .overlay(Color.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 10).stroke(style: .init()))
                            DatePicker("Select Alarm Time", selection: $appState.selectedTime, displayedComponents: [.hourAndMinute])
                                .datePickerStyle(WheelDatePickerStyle())
                                .labelsHidden()
                                .opacity(appState.isAlarmSet ? 0.0 : 1.0) // アラームが設定されていない場合に非表示
                                .disabled(appState.isAlarmSet) // アラームが設定されていない場合に無効化
                        }
                    }
                    
                    //&& isSnoozeEnabledの時のみ表示------------------------------------
                    //AudioPlayerをif文に入れない工夫が必要-------------//
                    
                    if appState.isAlarmSet && appState.isAlarmActive && appState.isSnoozeEnabled {
                        Button(action: {
                            blackFade()
                            let snoozeManager = SnoozeManager(appState: appState)
                            snoozeManager.stopAlarmSnooze()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                snoozeManager.setAlarmSnooze()
                            }
                        }) {
                            Text("Snooze")
                                .frame(width: 150, height: 80)
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                                .overlay(Color.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 10).stroke(style: .init()))
                        }
                    }
                    
                    //------------------------------------------------------------------
                    
                    ZStack {
                        
                        Rectangle()
                            .frame(height: 10)
                            .opacity(0.1)
                        
                        if appState.isVolumeControlEnabled {
                            
                            ZStack{
                                
                                VolumeView()
                                    .frame(width: 300, height: 0) // Adjust the frame as needed
                                
                                //SystemVolume連携させるスライダー
                                MPVolumeViewRepresentable(systemVolume: $appState.systemVolume, customSliderValue: $appState.customSliderValue)
                                    .frame(width: 300, height: 0)
                                
                                //表示する音量スライダー
                                Slider(value: Binding(get: {
                                    self.appState.customSliderValue
                                }, set: { newValue in
                                    self.appState.customSliderValue = newValue
                                    self.appState.systemVolume = newValue // 監視した変更をここで反映
                                }), in: 0...1)
                                .frame(width: 300, height: 0)
                                .accentColor(.white)
                                .disabled(true) // スライダーを操作不可能にする
                                .opacity(0) // スライダーを完全に見えなくする
                            }
                        }
                    }
                    
                    
                    //Button(action: {
                    
                    //    print("音量確認: \(AVAudioSession.sharedInstance().outputVolume)")
                    
                    //}) {
                    //    Text("音量確認")
                    //        .foregroundColor(.white)
                    //        .padding()
                    //        .background(Color.blue)
                    //        .cornerRadius(10)
                    //}
                    
                    Button(appState.buttonText) {
                        blackFade()
                        if appState.isAlarmSet {
                            let alarmManager = AlarmManager(appState: appState)
                            alarmManager.stopAlarm()
                        } else {
                            let alarmManager = AlarmManager(appState: appState)
                            alarmManager.setAlarm()
                        }
                    }
                    .frame(width: 150, height: 80)
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    .overlay(Color.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 10).stroke(style: .init()))
                    .padding()
                    
                }
                Color.black
                    .opacity(opacity)
                    .edgesIgnoringSafeArea(.all)
            }
            .onAppear {
                // Initialize the current time when the view appears
                updateTime()
                // Set up a timer to update the current time
                let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    updateTime()
                    
                    let alarmManager = AlarmManager(appState: appState)
                    alarmManager.checkAlarm()
                }
                // Make sure to add the timer to the run loop
                RunLoop.current.add(timer, forMode: .common)
                
                // ボタンアクションで音量調整を有効にする
                appState.isVolumeControlEnabled = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    //システムボリュームの値を一時保存
                    self.appState.temporaryValue = AVAudioSession.sharedInstance().outputVolume
                    print("temporaryValue:\(self.appState.temporaryValue)")
                    print("appState.systemVolume:\(self.appState.systemVolume)")
                    print("appState.customSliderValue:\(self.appState.customSliderValue)")
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    // ボタンアクションで音量調整を無効にする
                    self.appState.isVolumeControlEnabled = false
                }
            }
            
   //         .onChange(of: scenePhase) { newScenePhase in
    //            switch newScenePhase {
    //            case .active:
    //                print("Active")
    //            case .inactive:
    //                print("Inactive")
    //            case .background:
     //               print("Background")
     //               if appState.isAlarmSet{
    //                    let audioManager = AudioManager(appState: appState)
     //                   audioManager.playSound3()
     //                   let alarmManager = AlarmManager(appState: appState)
       //                 alarmManager.check()
       //             }
       //         @unknown default:
     //               print("Unknown")
    //            }
         //   }
        }
    }
    
    // アニメーションを実行する関数
    func blackFade() {
        // フェードインを開始
        withAnimation(.easeInOut(duration: 0.2)) {
            opacity = 1.0
        }
        // 1秒後にフェードアウトを開始
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            withAnimation(.easeInOut(duration: 0.2)) {
                opacity = 0.0
            }
        }
    }
    
    // 新しいプロパティと関数
    var selectedTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: appState.selectedTime)
    }
    
    func updateTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        appState.currentTimeString = formatter.string(from: Date())
    }
    
    func formatTime(_ seconds: Int) -> String {
        // 時間のフォーマットを整形する
        let minutes = (seconds % 3600) / 60
        let seconds = (seconds % 3600) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func isHeadphonesConnected() -> Bool {
        // ヘッドフォンが接続されているか確認する
        let currentRoute = AVAudioSession.sharedInstance().currentRoute
        for output in currentRoute.outputs {
            if output.portType == AVAudioSession.Port.headphones || output.portType == AVAudioSession.Port.bluetoothA2DP || output.portType == AVAudioSession.Port.bluetoothHFP {
                return true
            }
        }
        return false
    }

}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState()) // AppStateオブジェクトを提供
            .environmentObject(ImagePickerViewModel())
    }
}

// SwiftUIビューで使用するためにMPVolumeViewをラップする
struct VolumeView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MPVolumeView {
        let volumeView = MPVolumeView()
        volumeView.showsVolumeSlider = false // ボリュームスライダーを表示
        return volumeView
    }
    
    func updateUIView(_ uiView: MPVolumeView, context: Context) {
        // ビューの更新が必要な場合にここで処理します
    }
}

// MPVolumeViewをSwiftUIに組み込むためのUIViewRepresentable
struct MPVolumeViewRepresentable: UIViewRepresentable {
    @Binding var systemVolume: Float
    @Binding var customSliderValue: Float

    func makeUIView(context: Context) -> MPVolumeView {
        let volumeView = MPVolumeView()

        volumeView.isHidden = true
        
        // スライダーの値が変更されたときの処理を追加
        if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
            slider.addTarget(context.coordinator, action: #selector(Coordinator.volumeChanged(_:)), for: .valueChanged)
        }

        // スライダーの外観を設定
        if let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider {
            slider.minimumTrackTintColor = UIColor.blue
            slider.maximumTrackTintColor = UIColor.white
        }

        // UIViewRepresentableが持つUIViewを返す
        return volumeView
    }

    func updateUIView(_ uiView: MPVolumeView, context: Context) {
        // MPVolumeViewのスライダーの値が変更されたときに更新
        if let slider = uiView.subviews.first(where: { $0 is UISlider }) as? UISlider {
            slider.value = systemVolume
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: MPVolumeViewRepresentable

        init(_ parent: MPVolumeViewRepresentable) {
            self.parent = parent
        }

        // 音量が変更されたときに呼ばれる関数
        @objc func volumeChanged(_ sender: UISlider) {
            let volume = sender.value
            parent.systemVolume = volume
            // MPVolumeViewのスライダーの値が変更されたときにカスタムのスライダーに反映
            parent.customSliderValue = volume
        }
    }
}
