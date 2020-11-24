//
//  RandomStoryView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 24.11.2020.
//

import SwiftUI
import CoreData

struct RandomStoryViewWrapper: View {
    
    @Environment(\.managedObjectContext) private var context
    
    //@State private var refresh = true
    
    var body: some View {
        RandomStoryView(context: context)
    }
}

struct RandomStoryView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    //@Binding var refresh: Bool
    
    private var story: Story?
    
    @FetchRequest private var stories: FetchedResults<Story>
    
    init(context: NSManagedObjectContext) {
        let request = Story.requestRandom(in: context)
        _stories = FetchRequest(fetchRequest: request)
    }
    
    @State private var refresh = false
    
    var body: some View {
        NavigationView {
            Group {
                if let story = stories.first {
                    VStack(alignment: .leading) {
                        ScrollView {
                            Text(story.text)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                        Spacer()
                        
                        StoryTagView(tags: .constant(Set(story.tags)))
                            .disabled(true)
                    }
                    .padding()
                } else {
                    Text("Nothing fetched")
                }
            }
            .navigationTitle("Random Story")
            .navigationBarItems(trailing: magicButtton())
        }
    }
    
    func magicButtton() -> some View {
        return Button {
            let haptics = Haptics()
            haptics.feedback()
            
            withAnimation {
                refresh.toggle()
            }
        } label: {
            Image(systemName: "wand.and.stars")
                .frame(minWidth: 44, minHeight: 44, alignment: .topTrailing)
        }
    }
}

struct RandomStoryView_Previews: PreviewProvider {
    static var previews: some View {
        RandomStoryViewWrapper()
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .environment(\.colorScheme, .dark)
            .previewLayout(.fixed(width: 350, height: 600))
    }
}
