//
//  LaunchScreenView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 02.01.2024.
//

import SwiftUI

struct LaunchScreenView: View {
    
    var body: some View {
        
        VStack {
            
            Spacer()
            Spacer()
            Spacer()
            
            VStack {
            
                title()
                subtitle()
            }
            
            Spacer()
            
            copy()
        }
        .shadow(color: .black, radius: 6, x: 0.0, y: 0.0)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(paint())
    }
     
    private func title() -> some View {
        
        Text("Meme-Ory")
            .font(.largeTitle)
            .fontWeight(.bold)
    }

    private func subtitle() -> some View {
        
        Text("Collect your stories")
            .font(.subheadline)
    }
    
    private func copy() -> some View {
        
        Text("by Lorenhil")
            .font(.caption)
    }
    
    private func paint() -> some View {
        
        Image("paint")
            .resizable().aspectRatio(contentMode: .fill)
            .ignoresSafeArea(.all)
    }
}

#Preview {
    LaunchScreenView()
}
