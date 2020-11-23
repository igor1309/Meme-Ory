//
//  TagGridWrapperView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

struct TagGridWrapperView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.presentationMode) private var presentation
    
    @Binding var selected: Set<Tag>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name_, ascending: true)],
        animation: .default)
    private var tags: FetchedResults<Tag>
    
    @State private var newTagName = ""
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("New Tag Name", text: $newTagName)
                        .searchModifier(text: $newTagName)
                    
                    Button(action: createNewTagAndSelect) {
                        Image(systemName: "plus.square")
                    }
                    .disabled(newTagName.isEmpty)
                }
                .padding(.top)
                
                Divider().padding(.vertical)
                
                TagGridView(selected: $selected)
            }
            .padding()
            .navigationBarTitle("Tags")//, displayMode: .inline)
            .navigationBarItems(trailing: Button("Done") {
                presentation.wrappedValue.dismiss()
            })
        }
    }
    
    private func createNewTagAndSelect() {
        let haptics = Haptics()
        haptics.feedback()
        
        withAnimation {
            /// check if name is unique
            guard !tags.map(\.name).contains(newTagName) else {
                newTagName = ""
                return
            }
            
            let tag = Tag(context: context)
            tag.name = newTagName
            
            context.saveContext()
            selected.insert(tag)
            
            newTagName = ""
        }
    }
}

struct TagGridWrapperView_Testing: View {
    @State private var selected = Set<Tag>()
    
    var body: some View {
        TagGridWrapperView(selected: $selected)
    }
}

struct TagGridWrapperView_Previews: PreviewProvider {
    static var previews: some View {
        TagGridWrapperView_Testing()
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .previewLayout(.fixed(width: 350, height: 600))
            .preferredColorScheme(.dark)
    }
}
