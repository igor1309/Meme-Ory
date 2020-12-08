//
//  ListOptionView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 23.11.2020.
//

import SwiftUI

struct ListOptionView: View {
    
    @Environment(\.presentationMode) private var presentation
    
    @EnvironmentObject private var filter: Filter
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sort")) {
                    Toggle(isOn: $filter.sortOrder.areInIncreasingOrder) {
                        sortToggleLabel()
                    }
                    
                    Picker(selection: $filter.itemToSortBy, label: filter.itemToSortBy.label(prefix: "Sort Stories by ")) {
                        ForEach(Filter.SortByOptions.allCases, id: \.self) { item in
                            Label(item.rawValue, systemImage: item.icon)
                                .tag(item)
                        }
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
                
                Section(header: Text("Extra Filters")) {
                    Picker(selection: $filter.favoritesFilter, label: filter.favoritesFilter.label()) {
                        ForEach(Filter.FavoritesFilterOptions.allCases, id: \.self) { item in
                            Label(item.rawValue, systemImage: item.icon)
                                .tag(item)
                        }
                    }
                    
                    Picker(selection: $filter.remindersFilter, label: filter.remindersFilter.label()) {
                        ForEach(Filter.RemindersFilterOptions.allCases, id: \.self) { item in
                            Label(item.rawValue, systemImage: item.icon)
                                .tag(item)
                        }
                    }
                }
                
                Section(header: Text("Selected Tags")) {
                    if !filter.tags.isEmpty {
                        resetTagsButton()
                    }
                    
                    selectedTags()
                    
                    TagGridView(selected: $filter.tags)
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
        label(title: "List Limit: \(filter.listLimit)", subtitle: "Select number or stories to show", image: "arrow.up.and.down.circle")
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
        Text(filter.tagList.isEmpty ? "show all" : filter.tagList)
            .foregroundColor(filter.tagList.isEmpty ? .secondary : .primary)
            .font(.footnote)
    }
    
    private func resetTagsButton() -> some View {
        Button("Clear Tags") {
            filter.resetTags()
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

fileprivate struct ListOptionView_Texting: View {
    @State var filter = Filter()
    
    var body: some View {
        ListOptionView()
    }
}

struct ListOptionView_Previews: PreviewProvider {
    static var previews: some View {
        ListOptionView_Texting()
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .environmentObject(Filter())
            .previewLayout(.fixed(width: 350, height: 800))
            .preferredColorScheme(.dark)
    }
}
