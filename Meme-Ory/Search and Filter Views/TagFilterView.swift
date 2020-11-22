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

struct TagFilter_Previews: PreviewProvider {
    @State static var filter = Filter()
    
    static var previews: some View {
        TagFilterView(filter: $filter)
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 350, height: 400))
    }
}
