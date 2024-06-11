//
//  Glassmorphism.swift
//  AlarmAppWithoutBG
//
//  Created by 小松野蒼 on 2023/12/08.
//

//
//  Glassmorphism.swift
//  AlarmUI
//
//  Created by 小松野蒼 on 2023/11/15.
//
// Glassmorphism.swift

import SwiftUI

struct GlassmorphismButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
            .overlay(.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 10).stroke(style: .init()))
    }
}

extension ButtonStyle where Self == GlassmorphismButtonStyle {
    static var glassmorphism: GlassmorphismButtonStyle {
        .init()
    }
}

