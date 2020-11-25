//
//  TagView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

struct TagView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @ObservedObject var tag: Tag
    
    @Binding var selected: Set<Tag>
    
    let isSelected: Bool
    
    let cornerRadius: CGFloat = 6
    
    @State private var showDeleteConfirmation = false
    @State private var showEditTag = false
    
    var body: some View {
        Text(tag.name)
            .foregroundColor(isSelected ? Color(UIColor.systemOrange) : Color.secondary)
            .font(.footnote)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(isSelected ? Color(UIColor.systemFill) : Color(UIColor.secondarySystemFill))
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(isSelected ? Color(UIColor.systemOrange) : Color(UIColor.systemGray3))
            )
            .contextMenu {
                Button {
                    showEditTag = true
                } label: {
                    Label("Rename Tag", systemImage: "square.and.pencil")
                }
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Label("Delete Tag", systemImage: "trash.circle")
                }
            }
            .actionSheet(isPresented: $showDeleteConfirmation) {
                actionSheetDelete(tag: tag)
            }
            .sheet(isPresented: $showEditTag) {
                context.saveContext()
            } content: {
                TagEditView($tag.name)
            }
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
            
            context.delete(tag)
            context.saveContext()
        }
    }
    
}

fileprivate struct TagView_Testing: View {
    @State private var selected = Set<Tag>()
    
    var body: some View {
        TagView(tag: SampleData.tag, selected: $selected, isSelected: true)
        TagView(tag: SampleData.tag, selected: $selected, isSelected: false)
    }
}

struct TagView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HStack {
                TagView_Testing()
            }
            .navigationBarTitle("Tags", displayMode: .inline)
        }
        .previewLayout(.fixed(width: 350, height: 300))
        .environment(\.colorScheme, .dark)
    }
}
