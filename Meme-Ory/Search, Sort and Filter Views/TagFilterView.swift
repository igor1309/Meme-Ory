//
//  TagFilterView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

struct TagFilterView: View {
    @Environment(\.presentationMode) private var presentation
    
    @Binding var filter: Filter
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                selectedTags()
                
                Divider()
                
                TagGridView(selected: $filter.tags)
            }
            .padding()
            .navigationTitle("Tag Filter")
            .navigationBarItems(leading: clearFilterButton(),
                                trailing: doneButton())
        }
    }
    
    private func selectedTags() -> some View {
        return VStack(alignment: .leading, spacing: 6) {
            Text("Selected Tags".uppercased())
                .foregroundColor(.secondary)
                .font(.caption)
            
            Text(filter.tagList.isEmpty ? "<none>" : filter.tagList)
                .foregroundColor(filter.tagList.isEmpty ? .secondary : .primary)
                .font(.footnote)
        }
    }
    
    private func clearFilterButton() -> some View {
        Button("Clear") {
            filter.reset()
            presentation.wrappedValue.dismiss()
        }
        .disabled(filter.tags.isEmpty)
    }
    
    private func doneButton() -> some View {
        Button("Done") {
            presentation.wrappedValue.dismiss()
        }
    }
}

struct TagFilterView_Testing: View {
    @State var filter = Filter()
    
    var body: some View {
        TagFilterView(filter: $filter)
    }
}

struct TagFilter_Previews: PreviewProvider {
    
    static var previews: some View {
        TagFilterView_Testing()
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 350, height: 400))
    }
}
