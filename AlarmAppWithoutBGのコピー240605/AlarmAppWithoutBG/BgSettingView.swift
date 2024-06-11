//
//  BgSettingView.swift
//  AlarmAppWithoutBG
//
//  Created by 小松野蒼 on 2024/04/22.
//

import SwiftUI

struct BgSettingView: View {
    @EnvironmentObject var viewModel: ImagePickerViewModel

    var body: some View {
        ZStack {
            
            if let image = viewModel.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
            }
            
            VStack{
                
                Spacer()
                
                Button("Select Image") {
                    viewModel.presentPhotoPicker()
                }
                .frame(width: 150, height: 80)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                .overlay(Color.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 10).stroke(style: .init()))
                .padding(100)
            }
        }
    }
}

#Preview {
    BgSettingView()
        .environmentObject(ImagePickerViewModel())
}
