//
//  LoadingView.swift
//  xkcd
//
//  Created by Sylvan Martin on 11/29/25.
//

import SwiftUI
import Foundation

struct LoadingView: View {
    @Binding var completed: Double
    @Binding var total: Double
    
    var body: some View {
        ZStack {
            ProgressView(value: completed, total: total)
        }
        .frame(width: 200, height: 150)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
    
}
