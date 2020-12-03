//
//  StoryView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 03.12.2020.
//

import SwiftUI
import CoreData

struct PasteClipboardToStoryButton: View {
    @Environment(\.managedObjectContext) private var context
    
    let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    var body: some View {
        // if clipboard has text paste and save story
        Button {
            if UIPasteboard.general.hasStrings {
                let haptics = Haptics()
                haptics.feedback()
                
                withAnimation {
                    if let content = UIPasteboard.general.string,
                       !content.isEmpty {
                        let story = Story(context: context)
                        story.text = content
                        story.timestamp = Date()
                        
                        context.saveContext()
                        
                        action()
                    }
                }
            }
        } label: {
            Label("Paste to story", systemImage: "doc.on.clipboard")
        }
        .disabled(!UIPasteboard.general.hasStrings)
    }
}

struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                Capsule()
                    .foregroundColor(Color(UIColor.secondarySystemBackground))
            )
    }
}

extension View {
    func cardModifier() -> some View {
        self.modifier(CardModifier())
    }
}

struct StoryMenu: View {
    
    let story: Story
    
    var body: some View {
        Button {
            story.isFavorite.toggle()
        } label: {
            Label("Favorite", systemImage: "star")
        }
    }
}

struct StoryView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @State private var storyURL: URL?
    
    private var story: Story? {
        context.getObject(with: storyURL) as? Story
    }
    
    var body: some View {
        Group {
            if let story = story {
                VStack {
                    Group {
                        randomStoryButton()
                        
                        PasteClipboardToStoryButton {
                            storyURL = Story.last(in: context)?.url
                        }
                    }
                    .cardModifier()
                    .padding(.top)
                    
                    Divider()
                    
                    Image(systemName: story.isFavorite ? "star.fill" : "star")
                        .foregroundColor(story.isFavorite ? Color(UIColor.systemOrange) : Color(UIColor.systemBlue))
                    
                    Divider()
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        Text(story.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .contentShape(Rectangle())
                            .contextMenu {
                                StoryMenu(story: story)
                            }
                    }
                    
                    Spacer()
                }
            } else {
                Text("no such story")
                    .foregroundColor(.secondary)
            }
        }
        .onAppear(perform: getRandomStory)
        .onOpenURL(perform: handleOpenURL)
    }
    
    private func randomStoryButton() -> some View {
        Button {
            let haptics = Haptics()
            haptics.feedback()
            
            getRandomStory()
        } label: {
            Label("Random story", systemImage: "wand.and.stars")
        }
    }
    
    private func getRandomStory() {
        withAnimation {
            storyURL = Story.oneRandom(in: context)?.url
        }
    }
    
    private func handleOpenURL(url: URL) {
        #if DEBUG
        //print("handleOpenURL: \(url)")
        #endif
        
        let haptics = Haptics()
        haptics.feedback()
        
        //        withAnimation {
        storyURL = url
        //        }
    }
}

struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        StoryView()
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 350, height: 800))
    }
}
