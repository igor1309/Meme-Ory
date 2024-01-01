//
//  InfoView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 02.01.2024.
//

import SwiftUI

struct Info {
    
    let icon: String
    let title: String
    let subtitle: String
}

struct InfoView: View {
    
    let info: Info
    
    var body: some View {
        
        HStack(spacing: 16) {
            
            Image(systemName: info.icon)
                .imageScale(.large)
                .font(.largeTitle)
            
            VStack(alignment: .leading) {
                
                Text(info.title)
                
                Text(info.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .multilineTextAlignment(.leading)
        }
    }
}

#Preview {
    
    Group {
        
        InfoView(info: .a)
        InfoView(info: .b)
    }
    .padding()
    .preferredColorScheme(.dark)
}
