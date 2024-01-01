//
//  Onboarding.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 02.01.2024.
//

import SwiftUI

struct Onboarding: View {
    
    let infos: [Info]
    
    var body: some View {
        
        VStack(spacing: 32) {
            
            header()
            
            ForEach(infos, content: infoButton)
            
            footer()
        }
        .padding()
    }
    
    private func header() -> some View {
        
        VStack(spacing: 8) {
            
            Text("Onboarding")
                .font(.title3)
            
            Text("Leaves rustled gently in the breeze.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
    
    private func infoButton(_ info: Info) -> some View {
        
        Button {
            
        } label: {
            buttonLabel(info: info)
        }
    }
    
    private func buttonLabel(info: Info) -> some View {
        
        InfoView(info: info)
            .padding()
            .background(.ultraThinMaterial.opacity(0.06))
            .blur(style: .systemUltraThinMaterialDark)
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }
    
    private func footer() -> some View{
        
        Text("Tap to keep watching")
            .font(.headline)
    }
}

struct Onboarding_Previews: PreviewProvider {
    
    static var previews: some View {
        
        storyListView(.large)
            .overlay {
                
                Onboarding(infos: [.a, .b])
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundStyle(.white)
                    .blur(style: .systemUltraThinMaterialDark)
                    .ignoresSafeArea(.all)
            }
    }
    
    static func storyListView(
        _ displayMode: NavigationBarItem.TitleDisplayMode = .inline
    ) -> some View {
        NavigationView {
            StoryListView(
                stories: [PreviewArticle].preview,
                storyListRowView: { Text($0.text) },
                confirmDelete: { _ in }
            )
            .navigationTitle("Story List View")
            .navigationBarTitleDisplayMode(displayMode)
        }
        .environment(\.sizeCategory, .large)
        .environment(\.colorScheme, .dark)
        .previewLayout(.fixed(width: 350, height: 700))
    }
}

extension Info: Identifiable {
    
    var id: String { title }
}

// MARK: - Preview Content

extension Info {
    
    static let a: Self = .init(
        icon: "hand.draw",
        title: "Label",
        subtitle: "Leaves rustled gently in the breeze."
    )
    
    static let b: Self = .init(
        icon: "hand.draw",
        title: "Mysterious Figure",
        subtitle: "A mysterious figure appeared at midnight."
    )
}
