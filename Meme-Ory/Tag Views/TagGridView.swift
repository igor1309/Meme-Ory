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
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVGrid(columns: columns) {
                ForEach(tags) { tag in
                    Button {
                        toggleSelection(tag)
                    } label: {
                        TagView(tag: tag, isSelected: isSelected(tag))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .contextMenu {
                        Button {
                            showDeleteConfirmation = true
                        } label: {
                            Label("Delete Tag", systemImage: "trash.circle")
                        }
                    }
                    .actionSheet(isPresented: $showDeleteConfirmation) {
                        actionSheetDelete(tag: tag)
                    }
                }
                .padding()
            }
        }
    }
    
    private func toggleSelection(_ tag: Tag) {
        let haptics = Haptics()
        haptics.feedback()
        
        withAnimation {
            
            if isSelected(tag) {
                /// remove tag
                selected.remove(tag)
                //selected.removeAll { $0 == tag }
            } else {
                /// add tag
                selected.insert(tag)
                //selected.append(tag)
            }
        }
    }
    
    private func isSelected(_ tag: Tag) -> Bool {
        selected.contains(tag)
    }
    
    private func actionSheetDelete(tag: Tag) -> ActionSheet {
        ActionSheet(
            title: Text("Delete Tag"),
            message: Text("Are you sure you want to delete tag '\(tag.name)'"),
            buttons: [
                .destructive(Text("Yes, delete!")) { deleteTag(tag) },
                .cancel()
            ]
        )
    }
    
    private func deleteTag(_ tag: Tag) {
        let haptics = Haptics()
        haptics.feedback()
        
        withAnimation {
            selected.remove(tag)
            //  MARK: - FINISH THIS NOT WORKING
            //
            context.delete(tag)
            context.saveContext()
        }
    }
}

struct TagGridView_Testing: View {
    @State private var selected = Set<Tag>()
    
    var body: some View {
        TagGridView(selected: $selected)
    }
}

struct TagGridView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TagGridView_Testing()
        }
        .previewLayout(.fixed(width: 350, height: 500))
        .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
        .environment(\.colorScheme, .dark)
    }
}
