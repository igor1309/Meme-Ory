//
//  TagFilter.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

struct TagFilter: View {
    @Environment(\.presentationMode) private var presentation
    
    @Binding var filter: Filter
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Group {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Selected Tags".uppercased())
                            .foregroundColor(.secondary)
                            .font(.caption)
                        
                        Text(filter.tagList.isEmpty ? "—" :filter.tagList)
                            .font(.footnote)
                    }
                    
                    Divider()
                }
                .padding(.horizontal)
                
                TagGridView(selected: $filter.tags)
            }
            .navigationTitle("Tag Filter")
            .navigationBarItems(leading: clearFilterButton(), trailing: doneButton())
        }
    }
    private func clearFilterButton() -> some View {
        Button {
            filter.tags = Set()
        } label: {
            Text("Clear")
        }
        .disabled(filter.tags.isEmpty)
    }
    private func doneButton() -> some View {
        Button {
            presentation.wrappedValue.dismiss()
        } label: {
            Text("Done")
        }
    }
}

struct TagFilter_Testing: View {
    
    @State private var filter: Filter = Filter()
    
    var body: some View {
        TagFilter(filter: $filter)
    }
}

struct TagFilter_Testing_Previews: PreviewProvider {
    static var previews: some View {
        TagFilter_Testing()
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 350, height: 400))
    }
}
