//
//  ErrorSheet.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 28.11.2020.
//

import SwiftUI

struct ErrorSheet<V: View>: View {
    @Environment(\.presentationMode) private var presentation
    
    let message: String
    let button: () -> V
    
    init(message: String, button: @escaping () -> V) {
        self.message = message
        self.button = button
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text(message)
                    .foregroundColor(.red)
                    .navigationTitle("Error")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction, content: closeButton)
                    }
                
                button()
            }
        }
    }
    
    private func closeButton() -> some View {
        Button("Close") {
            presentation.wrappedValue.dismiss()
        }
    }
}

struct ErrorSheet_Previews: PreviewProvider {
    static var previews: some View {
        ErrorSheet(message: "Error getting import File URL.") {
            Button("Try again") {}
        }
        .environment(\.colorScheme, .dark)
    }
}
