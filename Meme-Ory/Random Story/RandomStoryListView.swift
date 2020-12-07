//
//  RandomStoryListView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 07.12.2020.
//

import SwiftUI
import CoreData
import Combine

final class RandomStoryListViewModel: ObservableObject {
    @Published var k = 5
    
    @Published private(set) var stories = [Story]()
    
    private let context: NSManagedObjectContext
    
    private let updateRequested = PassthroughSubject<Void, Never>()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        subscribe()
    }
    
    private func subscribe() {
        Publishers.CombineLatest($k, updateRequested)
            .map { (k, _) in
                self.context.randomObjects(k, ofType: Story.self)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stories in
                self?.stories = stories
            }
            .store(in: &cancellableSet)
    }
    
    private var cancellableSet = Set<AnyCancellable>()
    
    deinit {
        for cancell in cancellableSet {
            cancell.cancel()
        }
    }
    
    
    //  MARK: Functions
    
    func update() {
        Ory.withHapticsAndAnimation {
            self.updateRequested.send()
        }
    }
}

struct RandomStoryListView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @StateObject private var model: RandomStoryListViewModel
    
    init(context: NSManagedObjectContext) {
        _model = StateObject(wrappedValue: RandomStoryListViewModel(context: context))
    }
    
    private var columns: [GridItem] = [.init(.flexible())]
    
    var body: some View {
        VStack {
            HStack {
                Picker("# of stories", selection: $model.k) {
                    ForEach([5, 13, 25], id: \.self) { qty in
                        Text("\(qty)").tag(qty)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Button(action: model.update) {
                    Image(systemName: "wand.and.stars")
                        .cardModifier(padding: 6, cornerRadius: 6, strokeBorderColor: Color.clear, background: Color(UIColor.secondarySystemBackground))
                }
            }
            .padding()
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/, content: {
                    ForEach(model.stories) { story in
                        StoryListRowView(story: story, lineLimit: nil)
                            .padding(.horizontal)
                    }
                })
            }
            
//            List {
//                Section(header: Text("Stories: \(model.stories.count)")) {
//                    ForEach(model.stories) { story in
//                        StoryListRowView(story: story, font: .footnote, lineLimit: nil)
////                        Text(story.text)
////                            .font(.footnote)
////                            //.lineLimit(2)
////                            .padding(.vertical, 3)
//                    }
//                }
//            }
//            .listStyle(InsetGroupedListStyle())
            .onAppear(perform: model.update)
        }
    }
}

struct RamdonStoryListView_Previews: PreviewProvider {
    @State static var context = SampleData.preview.container.viewContext
    
    static var previews: some View {
        RandomStoryListView(context: context)
            .environment(\.sizeCategory, .extraLarge)
            .preferredColorScheme(.dark)
            .environment(\.managedObjectContext, context)
            .environmentObject(Filter())
            .environmentObject(EventStore())
    }
}
