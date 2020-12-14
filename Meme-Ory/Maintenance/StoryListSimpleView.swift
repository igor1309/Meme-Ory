//
//  StoryListSimpleView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SwiftUI

extension Int {
    var storySuffix: String {
        guard self >= 0 else { return "" }
        guard self != 1 else { return "1 Story" }
        return "\(self) Stories"
    }
}


extension MaintenanceViewModel {
    
    func fixNoTimestampStoryDuplicates(stories: FetchedResults<Story>) {
        /// remove text duplicates using Set
        let textsCopy = Set(stories.map(\.text))
        
        for story in stories {
            context.delete(story)
        }
        
        let date = Date()
        
        let tag = Tag(context: context)
        tag.name = "Date Fixing"
        
        for text in textsCopy {
            let story = Story(context: context)
            story.text = text
            story.timestamp = date
            story.tags.append(tag)
        }
        
        context.saveContext()
    }
}


//  MARK: - Story List Simple View
struct StoryListSimpleView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject var model: MaintenanceViewModel
    
    @FetchRequest private var stories: FetchedResults<Story>
    
    let kind: ListKind
    
    init(selectedDate: Date?, kind: ListKind) {
        self.init(selectedDate: selectedDate, selectedText: nil, kind: kind)
    }
    
    init(selectedText: String?, kind: ListKind) {
        self.init(selectedDate: nil, selectedText: selectedText, kind: kind)
    }
    
    private init(selectedDate: Date? = nil, selectedText: String? = nil, kind: ListKind) {
        self.kind = kind
        
        let predicate = kind.predicate(selectedTimestampDate: selectedDate, selectedText: selectedText)
        let fetchRequest = Story.fetchRequest(predicate)
        _stories = FetchRequest(fetchRequest: fetchRequest)
    }
    
    var body: some View {
        if !stories.isEmpty {
            Section(
                header: Text("\(kind.listHeader): \(stories.count)")
                    .if(kind == .withoutTimestamp || kind == .textDuplicates) { $0.foregroundColor(Color(UIColor.systemRed))
                    }
            ) {
                if kind == .withoutTimestamp {
                    MyButton(title: "Fix Timestamp for \(stories.count.storySuffix)", icon: "wand.and.stars") {
                        model.fixNoTimestampStoryDuplicates(stories: stories)
                    }
                }
                
                ForEach(stories, content: StoryListRowSimpleView.init)
                    .onDelete(perform: confirmDelete)
                    .actionSheet(isPresented: $showingConfirmation, content: confirmActionSheet)
            }
        }
    }
    
    @State private var showingConfirmation = false
    @State private var indexSet = IndexSet()
    
    private func confirmDelete(_ indexSet: IndexSet) {
        self.indexSet = indexSet
        showingConfirmation = true
    }
    
    private func confirmActionSheet() -> ActionSheet {
        ActionSheet(
            title: Text("Delete Story?".uppercased()),
            message: Text("Are you sure? This cannot be undone."),
            buttons: [
                .destructive(Text("Yes, delete!"), action: delete),
                .cancel()
            ]
        )
    }
    
    private func delete() {
        for index in indexSet {
            context.delete(stories[index])
        }
        
        context.saveContext()
    }
}


struct StoryListSimpleView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StoryListSimpleView(selectedDate: Date(), kind: .withTimestamp)
            StoryListSimpleView(selectedDate: Date(), kind: .withoutTimestamp)

            StoryListSimpleView(selectedText: "Some Text", kind: .textDuplicates)
        }
    }
}
