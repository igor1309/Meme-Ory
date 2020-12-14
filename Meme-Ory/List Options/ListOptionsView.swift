//
//  ListOptionsView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 09.12.2020.
//

import SwiftUI

struct ListOptionsView: View {
    
    @Environment(\.presentationMode) private var presentation
    
    @ObservedObject var model: MainViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sort")) {
                    Toggle(isOn: $model.listOptions.sortOrder.areInIncreasingOrder) {
                        sortToggleLabel()
                    }
                    
                    Picker(selection: $model.listOptions.itemToSortBy, label: model.listOptions.itemToSortBy.label(prefix: "Sort Stories by ")) {
                        ForEach(ListOptions.SortByOptions.allCases) { item in
                            item.label().tag(item)
                        }
                    }
                }
                
                Section(header: Text("Limit")) {
                    Toggle(isOn: $model.listOptions.isListLimited) {
                        limitLabel()
                    }
                    
                    if model.listOptions.isListLimited {
                        Picker(selection: $model.listOptions.listLimit, label: limitLabel()) {
                            ForEach(ListOptions.listLimitOptions, id:\.self) { item in
                                Text("\(item)").tag(item)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                Section(header: Text("Extra Filters")) {
                    Picker(selection: $model.listOptions.favoritesFilter, label: model.listOptions.favoritesFilter.label()) {
                        ForEach(ListOptions.FavoritesFilterOptions.allCases) { item in
                            item.label().tag(item)
                        }
                    }
                    
                    Picker(selection: $model.listOptions.remindersFilter, label: model.listOptions.remindersFilter.label(prefix: "Reminders: ")) {
                        ForEach(ListOptions.RemindersFilterOptions.allCases) { item in
                            item.label().tag(item)
                        }
                    }
                }
                
                Section(header: Text("Selected Tags")) {
                    if !model.listOptions.tags.isEmpty {
                        resetTagsButton()
                    }
                    
                    selectedTags()
                    
                    TagGridView(selected: $model.listOptions.tags)
                        .padding(.vertical, 6)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .accentColor(Color(UIColor.systemOrange))
            .navigationTitle("List Options")
            .navigationBarItems(trailing: doneButton())
        }
    }
    
    private func sortToggleLabel() -> some View {
        label(title: "Ascending", subtitle: "Select sort order", image: "arrow.up.arrow.down.circle")
    }
    
    private func limitLabel() -> some View {
        label(title: "List Limit: \(model.listOptions.listLimit)", subtitle: "Select number or stories to show", image: "arrow.up.and.down.circle")
    }
    
    private func label(title: String, subtitle: String? = nil, image: String) -> some View {
        Label {
            VStack(alignment: .leading) {
                Text(title)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
            }
        } icon: {
            Image(systemName: image)
                .imageScale(.large)
                .offset(y: subtitle == nil ? 0 : 6)
        }
        .accentColor(Color(UIColor.systemOrange))
    }
    
    private func selectedTags() -> some View {
        Text(model.listOptions.tagList.isEmpty ? "show all" : model.listOptions.tagList)
            .foregroundColor(model.listOptions.tagList.isEmpty ? .secondary : .primary)
            .font(.footnote)
    }
    
    private func resetTagsButton() -> some View {
        Button("Clear Tags") {
            model.listOptions.resetTags()
            presentation.wrappedValue.dismiss()
        }
        .disabled(model.listOptions.tags.isEmpty)
    }
    
    private func doneButton() -> some View {
        Button("Done") {
            presentation.wrappedValue.dismiss()
        }
    }
}

fileprivate struct ListOptionsView_Testing: View {
    @StateObject private var model = MainViewModel(context: SampleData.preview.container.viewContext)
    
    var body: some View {
        ListOptionsView(model: model)
    }
}

struct ListOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        ListOptionsView_Testing()
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .previewLayout(.fixed(width: 350, height: 800))
            .preferredColorScheme(.dark)
    }
}
