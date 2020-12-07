//
//  ShareStoryButtons.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 01.12.2020.
//

import SwiftUI

/// https://www.hackingwithswift.com/articles/118/uiactivityviewcontroller-by-example

struct ShareStoryButtons: View {
    let text: String
    let url: URL
    
    var body: some View {
        Section {
            Button {
                let items = [text]
                let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
                UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
            } label: {
                Label("Share story text", systemImage: "square.and.arrow.up")
            }
            
            Button {
                let items: [Any] = [text.appending("\n"), url]
                let av = UIActivityViewController(activityItems: items, applicationActivities: nil)
                UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
                
            } label: {
                Label("Share with link", systemImage: "square.and.arrow.up.on.square")
            }
        }
    }
}

struct ShareStoryView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            ShareStoryButtons(text: "Some nice story with or witout link", url: URL(string: "https://www.apple.com")!)
        }
        .preferredColorScheme(.dark)
        .previewLayout(.fixed(width: 350, height: 200))
    }
}
