//
//  ImportBriefView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 27.11.2020.
//

import SwiftUI

final class ImportBriefViewModel: ObservableObject {
    @Published var briefs: [Brief]
    
    var selectedBriefs: [Brief] {
        briefs.filter { $0.check }
    }
    
    var count: Int {
        briefs.count
    }
    var selectedCount: Int {
        briefs.filter { $0.check }.count
    }
    
    init(briefs: [Brief]) {
        self.briefs = briefs
    }
    
    func toggleCheck(for brief: Brief) {
        if let index = briefs.firstIndex(where: { $0.text == brief.text }) {
            briefs[index].check.toggle()
        }
    }
}

struct ImportBriefView: View {
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) private var presentation
    
    @StateObject var model: ImportBriefViewModel
    
    init(briefs: [Brief]) {
        _model = StateObject(wrappedValue: ImportBriefViewModel(briefs: briefs))
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Selected: \(model.selectedCount)")) {
                    ForEach(model.briefs, id: \.self, content: briefListRow)
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitle("Import", displayMode: .inline)
            .navigationBarItems(leading: cancelButton(), trailing: importButton())
        }
    }
    
    private func briefListRow(_ story: Brief) -> some View {
        Button {
            let haptics = Haptics()
            haptics.feedback()
            
            withAnimation {
                model.toggleCheck(for: story)
            }
        } label: {
            Label {
                Text("\(String(story.text.prefix(50)))...")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.subheadline)
                    .padding(.vertical, 3)
            } icon: {
                Image(systemName: story.check ? "checkmark.circle" : "circle")
                    .foregroundColor(story.check ? Color.green : .secondary)
                    .imageScale(.large)
                    .offset(y: 6)
            }
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
        ImportBriefView(briefs: Brief.examples)
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .environment(\.colorScheme, .dark)
    }
}
