//
//  ImportTextView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 27.11.2020.
//

import SwiftUI

struct ImportTextView: View {
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) private var presentation
    
    @StateObject var model: ImportTextViewModel
    
    let title: String
    
    init(url: URL, title: String = "Import") {
        print("ImportTextView.init(url:): \(url)")
        
        self.title = title
        
        _model = StateObject(wrappedValue: ImportTextViewModel(url: url))
    }
    
    init(texts: [String], title: String = "Import") {
        #if DEBUG
        print("ImportTextView.init(texts:): \((texts.first ?? "no texts").prefix(30))...")
        #endif
        
        _model = StateObject(wrappedValue: ImportTextViewModel(texts: texts))
        self.title = title
    }
    
    var body: some View {
        if model.briefs.isEmpty {
            NavigationView {
                VStack {
                    Text("Nothing to import or cannot parse this file\n(an array of strings would be ok)\n\nPlease try again if you are sure that file is ok")
                        .padding(.vertical)
                    
                    Text(model.string)
                        .foregroundColor(.secondary)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                }
                .padding()
                .navigationBarTitle("Import Fail", displayMode: .inline)
                .navigationBarItems(trailing: Button("Close") { presentation.wrappedValue.dismiss() })
            }
        } else {
            NavigationView {
                List {
                    Section(header: Text("Selected: \(model.selectedCount) of \(model.count)")) {
                        ForEach(model.briefs, content: briefListRow)
                    }
                }
                .listStyle(InsetGroupedListStyle())
                .navigationBarTitle(title, displayMode: .inline)
                .navigationBarItems(leading: cancelButton(), trailing: importButton())
            }
        }
    }
    
    private func briefListRow(_ story: Brief) -> some View {
        Button {
            Ory.withHapticsAndAnimation {
                model.toggleCheck(for: story)
            }
        } label: {
            HStack {
                Image(systemName: story.check ? "checkmark.circle" : "circle")
                    .foregroundColor(story.check ? Color.green : .secondary)
                    .imageScale(.large)
                
                Text("\(String(story.text.prefix(50)))...")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(story.check ? Color.primary : .secondary)
                    .font(.subheadline)
                    .padding(.vertical, 3)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func cancelButton() -> some View {
        Button("Cancel") {
            presentation.wrappedValue.dismiss()
        }
    }
    
    @State private var showConfirmation = false
    
    private func importButton() -> some View {
        Button("Import") {
            showConfirmation = true
        }
        .disabled(model.selectedCount == 0)
        .actionSheet(isPresented: $showConfirmation, content: confirmationActionSheet)
    }
    
    private func confirmationActionSheet() -> ActionSheet {
        ActionSheet(
            title: Text("Import Selected?".uppercased()),
            message: Text("Do you want to import selected stories?\nThis may result in duplicates."),
            buttons: [
                .default(Text("Yes, import selected (\(model.selectedCount))"), action: importSelected),
                .destructive(Text("Import all (\(model.count))"), action: importAll),
                .cancel()
            ]
        )
    }
    
    private func importSelected() {
        model.selectedBriefs.convertToStories(in: context)
        presentation.wrappedValue.dismiss()
    }
    
    private func importAll() {
        model.briefs.convertToStories(in: context)
        presentation.wrappedValue.dismiss()
    }
}

struct ImportBriefView_Previews: PreviewProvider {
    static var previews: some View {
        ImportTextView(texts: SampleData.texts)
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .environment(\.colorScheme, .dark)
    }
}
