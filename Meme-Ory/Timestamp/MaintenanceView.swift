//
//  MaintenanceView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 09.12.2020.
//

import SwiftUI
import CoreData
import Combine

struct Timestamp: Identifiable {
    let id = UUID()
    
    let date: Date
    let count: Int
}

struct TimestampPicker: View {
    
    @ObservedObject var model: MaintenanceViewModel
    
    var body: some View {
        Picker(selection: $model.timestampDate, label: labelForDate()) {
            Text("All").tag(Date?.none)
            ForEach(model.timestamps) { (timestamp: Timestamp?) in
                Label("\(timestamp?.date ?? .distantPast, formatter: shorterFormatter)", systemImage: "\(timestamp?.count ?? 0).circle")
                    .tag(timestamp?.date)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
    
    @ViewBuilder
    private func label(timestamp: Timestamp?) -> some View {
        if let timestamp = timestamp {
            Label("\(timestamp.date, formatter: shorterFormatter)", systemImage: "\(timestamp.count).circle")
                .tag(timestamp.date)
        } else {
            Label("Error: no date here", systemImage: "exclamationmark.triangle")
                .tag(Date?.none)
        }
    }
    
    @ViewBuilder
    private func labelForDate() -> some View {
        if let date = model.timestampDate {
            Label("\(date, formatter: mediumFormatter)", systemImage: "calendar.badge.clock")
        } else {
            Label("Select date to filter stories...", systemImage: "calendar.badge.clock")
        }
    }
}

final class MaintenanceViewModel: ObservableObject {
    
    @Published var timestampDate: Date?
    
    @Published var timestamps = [Timestamp]()
    
    let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
        fetch()
        subscribe()
    }
    
    var hasTimestampDate: Bool {
        timestampDate != nil
    }
    
    var timestampsCount: Int { timestamps.count }
    var timestampsTotal: Int { timestamps.reduce(0) { $0 + $1.count } }
    
    func splitText(_ text: String) -> [String] {
        let separator = "***"
        let components = text.components(separatedBy: separator)
        
        let cleaned = components
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        return cleaned
    }
    
    private var cancellableSet = Set<AnyCancellable>()
    
    deinit {
        for cancell in cancellableSet {
            cancell.cancel()
        }
    }
    
    private func subscribe() {
        // subscribe to changes (inserts) in context
        NotificationCenter.default.publisher(for: .NSManagedObjectContextObjectsDidChange)
            .compactMap { notification in
                let context = notification.object as? NSManagedObjectContext
                guard context == self.context else { return nil }
                
                guard let insertedStories = notification.userInfo?[NSInsertedObjectsKey] as? Set<Story> else { return nil }
                
                /// was any story inserted?
                return !insertedStories.isEmpty
            }
            .filter { $0 }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.fetch()
            }
            .store(in: &cancellableSet)
        
    }
    
    private func fetch() {
        print("running fetch @ TimestampListViewModel")
        let timestampKeyPath = #keyPath(Story.timestamp_)
        let timestampExpression = NSExpression(forKeyPath: timestampKeyPath)
        
        let count = NSExpressionDescription()
        count.name = "count"
        count.expression = NSExpression(forFunction: "count:", arguments: [timestampExpression])
        count.expressionResultType = .integer64AttributeType
        
        let request = NSFetchRequest<NSDictionary>()
        request.entity = Story.entity()
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [timestampKeyPath, count]
        request.propertiesToGroupBy = [timestampKeyPath]
        request.returnsDistinctResults = true
        
        let sortDescriptor = NSSortDescriptor(keyPath: \Story.timestamp_, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        guard let fetch = try? context.fetch(request) else { return }
        
        timestamps = fetch.compactMap { dic -> Timestamp? in
            guard let count = dic["count"] as? Int,
                  let date = dic["timestamp_"] as? Date else { return nil }
            
            return Timestamp(date: date, count: count)
        }
    }
    
}

fileprivate struct StorySimpleView: View {
    
    @Environment(\.presentationMode) private var presentation
    
    let text: String
    let tags: String
    let title: String
    
    init(text: String, title: String) {
        self.text = text
        self.tags = ""
        self.title = title
    }
    
    init(story: Story) {
        self.text = story.text
        self.tags = story.tagList
        self.title = "Story"
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text(tags)
                    .foregroundColor(.secondary)
                    .font(.caption)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.top, .horizontal])
                
                ScrollView {
                    Text(text)
                        .padding(.horizontal)
                }
            }
            .navigationBarTitle(title, displayMode: .inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    presentation.wrappedValue.dismiss()
                }
            )
        }
    }
}

fileprivate struct StoryListRowSimpleView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var model: MaintenanceViewModel
    
    @ObservedObject var story: Story
    
    @State private var sheetID: SheetID?
    
    enum SheetID: Identifiable {
        case split, showStory
        var id: Int { hashValue }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(story.text)
                .lineLimit(model.hasTimestampDate ? nil : 2)
                .font(.subheadline)
            
            if !story.tagList.isEmpty {
                Label(story.tagList, systemImage: "tag")
                    .foregroundColor(Color(UIColor.systemOrange))
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .padding(.vertical, 3)
        .onTapGesture(perform: showStory)
        .contextMenu(menuItems: menuContent)
        .sheet(item: $sheetID, content: splitView)
    }
    
    @ViewBuilder
    private func menuContent() -> some View {
        MyButton(title: "Show Story", icon: "doc.text.magnifyingglass", action: showStory)
        MyButton(title: "Split Story", icon: "scissors", action: splitStory)
    }
    
    private func showStory() {
        sheetID = .showStory
    }
    
    private func splitStory() {
        sheetID = .split
    }
    
    @ViewBuilder
    private func splitView(sheetID: SheetID) -> some View {
        switch sheetID {
            case .split:
                if model.splitText(story.text).count == 1 {
                    StorySimpleView(text: story.text, title: "Can't split this story")
                } else {
                    ImportTextView(texts: model.splitText(story.text), title: "Story Split")
                        .environment(\.managedObjectContext, context)
                }
                
            case .showStory:
                StorySimpleView(story: story)
        }
    }
}


extension MaintenanceViewModel {
    enum ListKind {
        case withTimestamp, withoutTimestamp
    }
    
    private var timestampPredicate: NSPredicate {
        if let timestampDate = timestampDate {
            return NSPredicate(format: "%K == %@", #keyPath(Story.timestamp_), timestampDate as NSDate)
        } else {
            return NSPredicate.all
        }
    }
    
    private var noTimestampPredicate: NSPredicate {
        NSPredicate(format: "%K == null", #keyPath(Story.timestamp_))
    }
    
    func predicate(kind: ListKind) -> NSPredicate {
        switch kind {
            case .withTimestamp:    return self.timestampPredicate
            case .withoutTimestamp: return self.noTimestampPredicate
        }
    }
    
    func listHeader(kind: ListKind) -> String {
        switch kind {
            case .withTimestamp:    return "Sorted by descending timestamзs"
            case .withoutTimestamp: return "no timestamp stories"
        }
    }
    
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


fileprivate struct StoryListSimpleView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject var model: MaintenanceViewModel
    
    @FetchRequest private var stories: FetchedResults<Story>
    
    let kind: MaintenanceViewModel.ListKind
    let header: String
    
    init(model: MaintenanceViewModel, kind: MaintenanceViewModel.ListKind) {
        self.kind = kind
        self.header = model.listHeader(kind: kind)
        
        let predicate = model.predicate(kind: kind)
        let sortDescriptor1 = NSSortDescriptor(key: #keyPath(Story.timestamp_), ascending: false)
        let sortDescriptor2 = NSSortDescriptor(key: #keyPath(Story.text_), ascending: false)
        let fetchRequest = Story.fetchRequest(predicate, sortDescriptors: [sortDescriptor1, sortDescriptor2])
        _stories = FetchRequest(fetchRequest: fetchRequest)
    }
    
    var body: some View {
        if !stories.isEmpty {
            Section(header: Text("\(header): \(stories.count)")) {
                if kind == .withoutTimestamp {
                    MyButton(title: "Fix No Timestamp Story Duplicates", icon: "wand.and.stars") {
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
    }
}

struct MaintenanceView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @StateObject private var model: MaintenanceViewModel
    
    init(context: NSManagedObjectContext) {
        _model = StateObject(wrappedValue: MaintenanceViewModel(context: context))
    }
    
    var body: some View {
        List {
            #if DEBUG
            Section(header: Text("Testing")) {
                MyButton(title: "Test: add more", icon: "plus.square", action: addMore)
                MyButton(title: "Test: add more NO DATE", icon: "plus.square.fill", action: addMoreNoDate)
                MyButton(title: "Test: add special story", icon: "plus.rectangle.on.rectangle", action: addSpecial)
            }
            #endif
            
            Section(header: Text("Filter")) {
                TimestampPicker(model: model)
            }
            
            StoryListSimpleView(model: model, kind: .withoutTimestamp)
            
            StoryListSimpleView(model: model, kind: .withTimestamp)
        }
        .listStyle(InsetGroupedListStyle())
        .environmentObject(model)
    }
    
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

fileprivate let mediumFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    return formatter
}()

fileprivate let shorterFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy HH:mm"
    //        formatter.dateStyle = .medium
    //        formatter.timeStyle = .short
    return formatter
}()

struct TimestampListView_Previews: PreviewProvider {
    static var previews: some View {
        MaintenanceView(context: SampleData.preview.container.viewContext)
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .environment(\.colorScheme, .dark)
    }
}
