
//  Created by 小松野蒼 on 2023/12/08.
//
//  Review.swift
//  AlarmUI
//
//  Created by 小松野蒼 on 2023/11/16.
//

import SwiftUI

struct Review: View {
    var body: some View {
        List {
            Section(header: Text("")) {
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
    }
}

struct ReviewView_Previews: PreviewProvider {
    static var previews: some View {
        Review()
    }
}


