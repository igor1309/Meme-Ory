//
//  MaintenanceView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 09.12.2020.
//

import SwiftUI
import CoreData
import Combine

struct TextDuplicate: Equatable, Identifiable {
    let id = UUID()
    
    let text: String
    let count: Int
}

struct TimestampDuplicate: Equatable, Identifiable {
    let id = UUID()
    
    let date: Date
    let count: Int
}


//  MARK: - Story Text Picker

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


//  MARK: - Timestamp Picker

struct TimestampPicker: View {
    
    @ObservedObject var model: MaintenanceViewModel
    
    var body: some View {
        Picker(selection: $model.selectedTimestampDate, label: label()) {
            Text("All Dates").tag(Date?.none)
            ForEach(model.timestampDuplicates) { (timestamp: TimestampDuplicate?) in
                Label("\(timestamp?.date ?? .distantPast, formatter: shorterFormatter)", systemImage: "\(timestamp?.count ?? 0).circle")
                    .tag(timestamp?.date)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
    private func label() -> some View {
        Group {
            if let date = model.selectedTimestampDate {
                Label("\(date, formatter: mediumFormatter)", systemImage: "calendar.badge.clock")
            } else {
                Label("Select Date to filter Stories", systemImage: "calendar.badge.clock")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

//  MARK: - Maintenance View Model
final class MaintenanceViewModel: ObservableObject {
    
    @Published var selectedTimestampDate: Date?
    @Published var timestampDuplicates = [TimestampDuplicate]()
    
    @Published var selectedText: String?
    @Published var textDuplicates = [TextDuplicate]()
    
    let context: NSManagedObjectContext
    
    var hasTimestampDate: Bool { selectedTimestampDate != nil }

    
    //  MARK: - Init & Subscribe
    
    init(context: NSManagedObjectContext) {
        self.context = context

        timestampDuplicates = fetchTimestampDuplicates(countMin: 2)
        textDuplicates = fetchTextDuplicates(countMin: 2)
        
        subscribe()
    }
    
    /// subscribe to changes in context
    private func subscribe() {
        
        // update timestampDuplicates & timestampDate
        context.anyChangePublisher
            .delay(for: 0.5, scheduler: DispatchQueue.global())
            .flatMap { _ in
                Just(self.fetchTimestampDuplicates(countMin: 2))
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (timestampDuplicates: [TimestampDuplicate]) in
                self?.timestampDuplicates = timestampDuplicates
                // nullify if timestampDate refers to date not present in timestampDuplicates
                if let timestampDate = self?.selectedTimestampDate,
                   !timestampDuplicates.map(\.date).contains(timestampDate) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self?.selectedTimestampDate = nil
                    }
                }
            }
            .store(in: &cancellableSet)
        
        // update textDuplicates & selectedText
        context.anyChangePublisher
            // without delay picker doesn't update after new objects inserted
            .delay(for: 0.5, scheduler: DispatchQueue.global())
            .flatMap { _ in
                Just(self.fetchTextDuplicates(countMin: 2))
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (textDuplicates: [TextDuplicate]) in
                self?.textDuplicates = textDuplicates
                // nullify if selectedText refers to text not present in textDuplicates
                if let selectedText = self?.selectedText,
                   !textDuplicates.map(\.text).contains(selectedText) {
                    // @FetchRequest in StoryListSimpleView is quick to update itself
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self?.selectedText = nil
                    }
                }
            }
            .store(in: &cancellableSet)
        
    }
    
    private var cancellableSet = Set<AnyCancellable>()
    
    deinit {
        for cancell in cancellableSet {
            cancell.cancel()
        }
    }
    
    
    //  MARK: - Fetch & Transform
    
    private func fetchTimestampDuplicates(countMin: Int = 2) -> [TimestampDuplicate] {
        returnFetch(keyPath: \Story.timestamp_, countMin: countMin, transform: transform)
    }
    
    private func fetchTextDuplicates(countMin: Int = 2) -> [TextDuplicate]{
        returnFetch(keyPath: \Story.text_, countMin: countMin, transform: transform)
    }
    
    private func transform(_ dic: NSDictionary) -> TimestampDuplicate? {
        guard let count = dic["count"] as? Int,
              let date = dic["timestamp_"] as? Date else { return nil }
        
        return TimestampDuplicate(date: date, count: count)
    }
    
    private func transform(_ dic: NSDictionary) -> TextDuplicate? {
        guard let count = dic["count"] as? Int,
              let text = dic["text_"] as? String else { return nil }
        
        return TextDuplicate(text: text, count: count)
    }
    
    private func returnFetch<T, Value>(keyPath: KeyPath<Story, Value>, countMin: Int = 2, transform: (NSDictionary) -> T?) -> [T] {
        
        // https://stackoverflow.com/a/38150048/11793043
        // https://stackoverflow.com/a/38313716/11793043

        let keyPathString = NSExpression(forKeyPath: keyPath).keyPath
        
        print("running generic returnFetch @ MaintenanceViewModel for \(keyPathString)")
        
        let attributeExpression = NSExpression(forKeyPath: keyPathString)
        
        let count = NSExpressionDescription()
        count.name = "count"
        count.expression = NSExpression(forFunction: "count:", arguments: [attributeExpression])
        count.expressionResultType = .integer64AttributeType
        
        let countExpression = NSExpression(forVariable: "count")
        
        let request = NSFetchRequest<NSDictionary>()
        request.entity = Story.entity()
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [keyPathString, count]
        request.propertiesToGroupBy = [keyPathString]
        request.returnsDistinctResults = true
        request.havingPredicate = NSComparisonPredicate(
            leftExpression: countExpression,
            rightExpression: NSExpression(forConstantValue: countMin),
            modifier: NSComparisonPredicate.Modifier.direct,
            type: NSComparisonPredicate.Operator.greaterThanOrEqualTo,
            options: [])
        
        let sortDescriptor = NSSortDescriptor(keyPath: keyPath, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        guard let fetch = try? context.fetch(request) else { return [] }
        
        let result = fetch.compactMap(transform)
        return result
    }
    
}

//  MARK: - Story Simple View
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

//  MARK: - Story List Row Simple View
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
                let split = story.text.splitText()
                if split.count == 1 {
                    StorySimpleView(text: story.text, title: "Can't split this story")
                } else {
                    ImportTextView(texts: split, title: "Story Split")
                        .environment(\.managedObjectContext, context)
                }
                
            case .showStory:
                StorySimpleView(story: story)
        }
    }
}


//  MARK: - List Kind enum
enum ListKind {
    case withTimestamp, withoutTimestamp, textDuplicates
    
    var listHeader: String {
        switch self {
            case .withTimestamp:    return "Sorted by descending timestamps"
            case .withoutTimestamp: return "No Timestamp Stories"
            case .textDuplicates:   return "Duplicates with Selected Text"
        }
    }
    
    func predicate(selectedTimestampDate: Date?, selectedText: String?) -> NSPredicate {
        switch self {
            case .withTimestamp:    return timestampPredicate(selectedTimestampDate)
            case .withoutTimestamp: return noTimestampPredicate
            case .textDuplicates:   return predicateForSelectedText(selectedText)
        }
    }
    
    private func predicateForSelectedText(_ selectedText: String?) -> NSPredicate {
        if let selectedText = selectedText {
            return NSPredicate(format: "%K == %@", #keyPath(Story.text_), selectedText)
        } else {
            return NSPredicate.none
        }
    }

    private func timestampPredicate(_ selectedTimestampDate: Date?) -> NSPredicate {
        if let timestampDate = selectedTimestampDate {
            return NSPredicate(format: "%K == %@", #keyPath(Story.timestamp_), timestampDate as NSDate)
        } else {
            return NSPredicate.all
        }
    }
    
    private var noTimestampPredicate: NSPredicate {
        NSPredicate(format: "%K == null", #keyPath(Story.timestamp_))
    }
}


//  MARK: - Maintenance View Model extension
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

extension Int {
    var storySuffix: String {
        guard self >= 0 else { return "" }
        guard self != 1 else { return "1 Story" }
        return "\(self) Stories"
    }
}


//  MARK: - Story List Simple View
fileprivate struct StoryListSimpleView: View {
    
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

//  MARK: - Maintenance View
struct MaintenanceView: View {
    
    @Environment(\.managedObjectContext) private var context
    
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
    }
    }
    
    @ViewBuilder
    private func toolbar() -> some View {
        #if DEBUG
        Menu {
            Section(header: Text("Testing")) {
                MyButton(title: "Add more Stories", icon: "plus.square", action: addMore)
                MyButton(title: "Add more NO DATE", icon: "plus.diamond", action: addMoreNoDate)
                MyButton(title: "Add Special Story", icon: "plus.rectangle.on.rectangle", action: addSpecial)
            }
        } label: {
            Image(systemName: "target")
        }
        #endif
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
        //NavigationView {
            MaintenanceView(context: SampleData.preview.container.viewContext)
        //}
        .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
        .environment(\.colorScheme, .dark)
    }
}



//  MARK: - Maintenance View Model extension
extension MaintenanceViewModel {
    private func fetchTimestampDuplicates(countMin: Int = 2) {
        fetch(keyPath: \Story.timestamp_, countMin: countMin, transform: transform) {
            self.timestampDuplicates = $0
        }
    }
    
    private func fetchTextDuplicates(countMin: Int = 2) {
        fetch(keyPath: \Story.text_, countMin: countMin, transform: transform) {
            self.textDuplicates = $0
        }
    }
    
    private func fetch<T, Value>(
        keyPath: KeyPath<Story, Value>,
        countMin: Int = 2,
        transform: (NSDictionary) -> T?,
        completion: @escaping ([T]) -> Void
    ) {
        let keyPathString = NSExpression(forKeyPath: keyPath).keyPath
        
        print("running generic fetch @ MaintenanceViewModel for \(keyPathString)")
        
        let attributeExpression = NSExpression(forKeyPath: keyPathString)
        
        let count = NSExpressionDescription()
        count.name = "count"
        count.expression = NSExpression(forFunction: "count:", arguments: [attributeExpression])
        count.expressionResultType = .integer64AttributeType
        
        let countExpression = NSExpression(forVariable: "count")
        
        let request = NSFetchRequest<NSDictionary>()
        request.entity = Story.entity()
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [keyPathString, count]
        request.propertiesToGroupBy = [keyPathString]
        request.returnsDistinctResults = true
        // https://stackoverflow.com/a/38150048/11793043
        request.havingPredicate = NSComparisonPredicate(
            leftExpression: countExpression,
            rightExpression: NSExpression(forConstantValue: countMin),
            modifier: NSComparisonPredicate.Modifier.direct,
            type: NSComparisonPredicate.Operator.greaterThanOrEqualTo,
            options: [])
        
        
        let sortDescriptor = NSSortDescriptor(keyPath: keyPath, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        guard let fetch = try? context.fetch(request) else { return }
        
        let result = fetch.compactMap(transform)
        completion(result)
    }
    
}

//  MARK: - Original Non-generic fetch as reference
private extension MaintenanceViewModel {
    
    /// Just a backup `not for use`
    private func nonGenericFetch() {
        print("running fetch @ MaintenanceViewModel")
        
        let timestampKeyPath = #keyPath(Story.timestamp_)
        let timestampExpression = NSExpression(forKeyPath: timestampKeyPath)
        
        let count = NSExpressionDescription()
        count.name = "count"
        count.expression = NSExpression(forFunction: "count:", arguments: [timestampExpression])
        count.expressionResultType = .integer64AttributeType
        
        let countExpression = NSExpression(forVariable: "count")
        
        let request = NSFetchRequest<NSDictionary>()
        request.entity = Story.entity()
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [timestampKeyPath, count]
        request.propertiesToGroupBy = [timestampKeyPath]
        request.returnsDistinctResults = true
        request.havingPredicate = NSPredicate(format: "%@ >= 1", countExpression)
        
        let sortDescriptor = NSSortDescriptor(keyPath: \Story.timestamp_, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        guard let fetch = try? context.fetch(request) else { return }
        
        timestampDuplicates = fetch.compactMap { dic -> TimestampDuplicate? in
            guard let count = dic["count"] as? Int,
                  let date = dic["timestamp_"] as? Date else { return nil }
            
            return TimestampDuplicate(date: date, count: count)
        }
    }
    
    
}

