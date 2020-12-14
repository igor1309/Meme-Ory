//
//  ListActionButtons.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SwiftUI

struct ListActionButtons: View {
    
    @EnvironmentObject private var model: MainViewModel
    
    var labelStyle: LabeledButton.Style = .none
    
    /// list limit and reminders aren't important to be menu, leaving them in options sheet
    var showUnimportant: Bool = false
    
    var body: some View {
        Section(header: Text("Create")) {
            LabeledButton(title:"Paste to New Story", icon: "doc.on.clipboard", labelStyle: labelStyle, action: model.pasteToNewStory)
            // to disable with .hasStrings its value should be updated
            //.disabled(!UIPasteboard.general.hasStrings)
            
            LabeledButton(title:"New Story", icon: "plus", labelStyle: labelStyle, action: model.createNewStory)
        }
        
        Section(header: Text("Shuffle List")) {
            LabeledButton(title: "Shuffle List", icon: "wand.and.stars", action: model.shuffleList)
                .disabled(true)
        }
        
        /// reset filter by tag(s)
        if model.listOptions.isTagFilterActive {
            Section {
                LabeledButton(title: "Reset Tags", icon: "tag.slash.fill", action: model.resetTags)
            }
        }
        
        if showUnimportant {
            Section {
                /// list limit
                LabeledButton(title: model.listOptions.isListLimited ? "Reset List Limit": "Set last Limit (\(model.listOptions.listLimit))", icon: model.listOptions.isListLimited ? "infinity" : "arrow.up.and.down") {
                    model.listOptions.isListLimited.toggle()
                }
                
                Section {
                    Menu {
                        Picker("Reminders", selection: $model.listOptions.remindersFilter) {
                            ForEach(ListOptions.RemindersFilterOptions.allCases) { option in
                                option.label().tag(option)
                            }
                        }
                    } label: {
                        Label(model.listOptions.remindersFilter.rawValue, systemImage: model.listOptions.remindersFilter.icon)//chevron.right")
                    }
                }
            }
        }
        
        Section(header: Text("Favorites")) {
            Menu {
                Picker("Favorites", selection: $model.listOptions.favoritesFilter) {
                    ForEach(ListOptions.FavoritesFilterOptions.allCases) { option in
                        option.label().tag(option)
                    }
                }
            } label: {
                Label(model.listOptions.favoritesFilter.rawValue, systemImage: model.listOptions.favoritesFilter.icon)//chevron.right")
            }
        }
        
        Section(header: Text("Sort")) {
            /// change item to sort by
            Picker("Sort by", selection: $model.listOptions.itemToSortBy) {
                ForEach(ListOptions.SortByOptions.allCases) { option in
                    option.label().tag(option)
                }
            }
            
            
            Picker("SortOrder", selection: $model.listOptions.sortOrder) {
                ForEach(ListOptions.SortOrder.allCases) { order in
                    order.label().tag(order)
                }
            }
        }
        
        Section {
            LabeledButton(title: "Show Options", icon: "slider.horizontal.3", action: model.showListOptions)
        }
        
    }
}


struct ListActionButtons_Previews: PreviewProvider {
    @State static private var context = SampleData.preview.container.viewContext
    
    static var previews: some View {
        List {
            ListActionButtons()
        }
        .listStyle(InsetGroupedListStyle())
        .environmentObject(MainViewModel(context: context))
        .preferredColorScheme(.dark)
        .previewLayout(.fixed(width: 350, height: 600))
    }
}
