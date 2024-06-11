
//  AlarmUIApp.swift
//  AlarmUI
//
//  Created by 小松野蒼 on 2023/11/15.
//

import SwiftUI
import AVFoundation

@main
struct AlarmUIApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var showingSplashView = true
    @StateObject private var appState = AppState()
    @StateObject var viewModel = ImagePickerViewModel()
    
    var body: some Scene {
        WindowGroup {
            if showingSplashView {
                SplashView()
                    .environmentObject(viewModel)
                    .onAppear {
                        // スプラッシュ画面の表示後、指定の時間（3秒）でAlarmAppに遷移
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            showingSplashView = false
                        }
                    }
            } else {
                ContentView()
                    .environmentObject(appState)
                    .environmentObject(viewModel)
            }
        }
    }
}

struct SplashView: View {
    
    @EnvironmentObject var viewModel: ImagePickerViewModel
    
    @State private var opacity: Double = 1.0
    @State private var colorOpacity: Double = 1.0

    var body: some View {
        ZStack {
            
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
            
            Color(white: 0.1)
                .ignoresSafeArea()
                .opacity(colorOpacity)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 0.5).delay(2.0)) {
                        colorOpacity = 0
                    }
                }

            Text("EARPHONE ALARM")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .opacity(opacity)
                .onAppear {
                    withAnimation(Animation.easeInOut(duration: 0.5).delay(2.0)) {
                        opacity = 0
                    }
                }
        }
    }
}
