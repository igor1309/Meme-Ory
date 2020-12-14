//
//  MaintenanceView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 09.12.2020.
//

import SwiftUI
import CoreData

struct MaintenanceView: View {
    
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) private var presentation
    
    @StateObject private var model: MaintenanceViewModel
    
    init(context: NSManagedObjectContext) {
        _model = StateObject(wrappedValue: MaintenanceViewModel(context: context))
    }
    
    var body: some View {
        NavigationView {
            List {
                Section(
                    header: Text("Filter Stories by Timestamp"),
                    footer: Text("Timestamps for two or more stories. If empty then there is just one story for each timestamp.")
                ) {
                    TimestampPicker(model: model)
                    
                }
                
                Section(
                    header: Text("Text Duplicates"),
                    footer: Text("If no options to select from then no duplicates of stories' texts.")
                ) {
                    StoryTextPicker(model: model)
                }
                
                StoryListSimpleView(selectedText: model.selectedText, kind: .textDuplicates)
                
                StoryListSimpleView(selectedDate: model.selectedTimestampDate, kind: .withoutTimestamp)
                
                StoryListSimpleView(selectedDate: model.selectedTimestampDate, kind: .withTimestamp)
            }
            .listStyle(InsetGroupedListStyle())
            .environmentObject(model)
            .navigationBarTitle("Maintenance", displayMode: .inline)
            .toolbar(content: toolbar)
            .actionSheet(item: $actionID, content: actionSheet)
            .confirmAndDelete($actionID, title: "Delete Selected Stories?".uppercased()) { _ in
                delete()
            }
        }
    }
    
    @State private var actionID: ActionID?
    
    enum ActionID: Identifiable {
        case confirmDelete
        var id: Int { hashValue }
    }
    
    private func actionSheet(actionID: ActionID) -> ActionSheet {
        switch actionID {
            case .confirmDelete:
                return ActionSheet(
                    title: Text("Delete Selected Stories?".uppercased()),
                    message: Text("Are you sure? This cannot be undone."),
                    buttons: [
                        .destructive(Text("Yes, delete!"), action: delete),
                        .cancel()
                    ]
                )
        }
    }
    
    private func delete() {
        Ory.withHapticsAndAnimation {
            context.deleteStories(withTag: model.markDeleteTag)
            print("stories with tag '\(model.markDeleteTag.name)' deleted")
        }
    }
    
    @ToolbarContentBuilder
    private func toolbar() -> some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                #if DEBUG
                Section(header: Text("Testing")) {
                    LabeledButton(title: "Add more Stories", icon: "plus.square", action: addMore)
                    LabeledButton(title: "Add more NO DATE", icon: "plus.diamond", action: addMoreNoDate)
                    LabeledButton(title: "Add Special Story", icon: "plus.rectangle.on.rectangle", action: addSpecial)
                }
                #endif
                
                LabeledButton(title: "Delete Marked", icon: "trash") {
                    actionID = .confirmDelete
                }
            } label: {
                Image(systemName: "target")
            }
        }
        
        ToolbarItem(placement: .cancellationAction) {
            Button("Close") {
                presentation.wrappedValue.dismiss()
            }
        }
    }
    
    
    //  MARK: - Testing
    
    #if DEBUG
    private func addMore() {
        let date = Date()
        let random = Int.random(in: 2..<10)
        
        for i in 1..<random {
            let story = Story(context: context)
            story.text = "Test Story #\(i)"
            story.timestamp = date
        }
        
        context.saveContext()
    }
    
    private func addMoreNoDate() {
        let random = Int.random(in: 2..<10)
        
        for i in 1..<random {
            let story = Story(context: context)
            story.text = "Test Story #\(i)"
        }
        
        context.saveContext()
    }
    
    private func addSpecial() {
        let story = Story(context: context)
        story.text = """

            ***

            — Ребе, тут в Торе пропуск!
            — Не говори чепуху!
            — Посмотрите сами, тут написано: не пожелай жены ближнего своего. А почему нигде нет: не пожелай мужа ближней своей?
            — Ну-уу… Пускай она даже пожелает - ему-то все равно нельзя!

            ***

            — Яша, я уже вышла из ванны и жду неприличных предложений…
            — Софочка, а давай заправим оливье кетчупом.
            — Нет, Яша, это уже перебор!

            ***

            — Моня, почему ты не даришь мне цветы?
            — Циля, я подарил тебе весь мир! Иди нюхай цветы на улицу!..

            ***

            — Беня, я гарантирую вам, шо через пять лет мы будем жить лучше, чем в Европе!
            — А шо у них случится?

            ***

            — Семочка, если будешь хорошо себя вести, купим тебе велосипед!
            — А если плохо?
            — Пианино!

            ***


            """
        story.timestamp = Date()
        
        context.saveContext()
    }
    #endif
}

struct TimestampListView_Previews: PreviewProvider {
    static var previews: some View {
        MaintenanceView(context: SampleData.preview.container.viewContext)
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .environment(\.colorScheme, .dark)
    }
}



