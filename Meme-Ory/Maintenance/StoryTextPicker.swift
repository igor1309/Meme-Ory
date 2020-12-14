//
//  StoryTextPicker.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SwiftUI

struct StoryTextPicker: View {
    
    @ObservedObject var model: MaintenanceViewModel
    
    var body: some View {
        if model.textDuplicates.isEmpty {
            Text("No Text Duplicates found")
                .foregroundColor(Color(UIColor.systemGreen))
        } else {
            picker()
        }
    }
    
    private func picker() -> some View {
        Picker(selection: $model.selectedText, label: label()) {
            Text("None").tag(String?.none)
            ForEach(model.textDuplicates) { (storyText: TextDuplicate?) in
                Label((storyText?.text ?? "error").oneLinePrefix(20), systemImage: "\(storyText?.count ?? 0).circle")
                    .tag(storyText?.text)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
    
    private func label() -> some View {
        Label((model.selectedText ?? "Select Duplicates").oneLinePrefix(20), systemImage: "calendar.badge.clock")
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
    }
}

struct StoryTextPicker_Previews: PreviewProvider {
    static var previews: some View {
        Form {
        StoryTextPicker(model: MaintenanceViewModel(context: SampleData.preview.container.viewContext))
        }
        .environment(\.colorScheme, .dark)
    }
}
