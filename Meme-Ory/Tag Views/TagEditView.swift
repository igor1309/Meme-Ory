//
//  TagEditView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 26.11.2020.
//

import SwiftUI

struct TagEditView: View {
    
    @Environment(\.presentationMode) private var presentation
    
    @Binding var text: String
    
    init(_ text: Binding<String>) {
        _text = text
        _draft = State(initialValue: text.wrappedValue)
    }
    
    @State private var draft: String
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tag Name")) {
                    TextField("tag Name", text: $draft)
                }
            }
            .navigationBarTitle("Edit tag", displayMode: .inline)
            .navigationBarItems(leading: cancelButton(), trailing: saveButton())
        }
    }
    
    private func cancelButton() -> some View {
        Button("Cancel") {
            presentation.wrappedValue.dismiss()
        }
    }
    
    private func saveButton() -> some View {
        Button("Save") {
            text = draft
            presentation.wrappedValue.dismiss()
        }
    }
}

struct TagEditView_Previews: PreviewProvider {
    @State static var text = "tag1"
    
    static var previews: some View {
        TagEditView($text)
    }
}
