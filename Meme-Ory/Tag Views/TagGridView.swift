//
//  TagGridView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

struct TagGridView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name_, ascending: true)],
        animation: .default)
    private var tags: FetchedResults<Tag>
    
    let columns = Array(repeating: GridItem(.adaptive(minimum: 60), spacing: 6), count: 4)
    
    @Binding var selected: Set<Tag>
    
    var body: some View {
        if tags.isEmpty {
            Text("No tags")
                .foregroundColor(.secondary)            
        } else {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    LazyVGrid(columns: columns) {
                        ForEach(tags) { tag in
                            Button {
                                toggleSelection(tag)
                            } label: {
                                TagView(tag: tag, selected: $selected, isSelected: isSelected(tag))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
        }
    }
    
    private func toggleSelection(_ tag: Tag) {
        Ory.withHapticsAndAnimation {
            if isSelected(tag) {
                /// remove tag
                selected.remove(tag)
            } else {
                /// add tag
                selected.insert(tag)
            }
        }
    }
    
    private func isSelected(_ tag: Tag) -> Bool {
        selected.contains(tag)
    }
}

fileprivate struct TagGridView_Testing: View {
    @State private var selected = Set<Tag>()
    
    var body: some View {
        TagGridView(selected: $selected)
    }
}

struct TagGridView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                TagGridView_Testing()
                    .navigationBarTitleDisplayMode(.inline)
            }
            .previewLayout(.fixed(width: 250, height: 300))
            
            NavigationView {
                TagGridView_Testing()
                    .navigationBarTitleDisplayMode(.inline)
            }
            .previewLayout(.fixed(width: 400, height: 200))
        }
        .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
        .environment(\.colorScheme, .dark)
    }
}
