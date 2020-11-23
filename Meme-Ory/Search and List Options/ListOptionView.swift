//
//  ListOptionView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 23.11.2020.
//

import SwiftUI

struct ListOptionView: View {
    
    @Environment(\.presentationMode) private var presentation
    
    @Binding var filter: Filter
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sort")) {
                    Toggle(isOn: $filter.areInIncreasingOrder) {
                        sortToggleLabel()
                    }
                }
                
                Section(header: Text("Limit")) {
                    Toggle(isOn: $filter.isListLimited) {
                        limitLabel()
                    }
                    
                    if filter.isListLimited {
                        Picker(selection: $filter.listLimit, label: limitLabel()) {
                            ForEach(Filter.listLimitOptions, id: \.self) { item in
                                Text("\(item)").tag(item)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                Section(header: Text("Selected Tags")) {
                    selectedTags()
                    
                    TagGridView(selected: $filter.tags)
                        .padding(.vertical, 6)
                }
            }
            .navigationTitle("List Options")
            .navigationBarItems(leading: resetTagsButton(), trailing: doneButton())
        }
    }
    
    private func sortToggleLabel() -> some View {
        label(title: "Ascending", subtitle: "Select sort order", image: "arrow.up.arrow.down.square")
    }
    
    private func limitLabel() -> some View {
        label(title: "List Limit", subtitle: "Select number or stories to show", image: "arrow.up.and.down.square")
    }
    
    private func label(title: String, subtitle: String, image: String) -> some View {
        Label {
            VStack(alignment: .leading) {
                Text(title)
                Text(subtitle)
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        } icon: {
            Image(systemName: image)
                .imageScale(.large)
                .offset(y: 6)
        }
        .accentColor(Color(UIColor.systemOrange))
    }
    
    private func selectedTags() -> some View {
        Text(filter.tagList.isEmpty ? "show all" : filter.tagList)
            .foregroundColor(filter.tagList.isEmpty ? .secondary : .primary)
            .font(.footnote)
    }
    
    private func resetTagsButton() -> some View {
        Button("Clear Tags") {
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

struct ListOptionView_Texting: View {
    @State var filter = Filter()
    
    var body: some View {
        ListOptionView(filter: $filter)
    }
}

struct ListOptionView_Previews: PreviewProvider {
    static var previews: some View {
        ListOptionView_Texting()
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .previewLayout(.fixed(width: 350, height: 800))
            .preferredColorScheme(.dark)
    }
}
