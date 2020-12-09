//
//  RandomListOptionsMenu.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 08.12.2020.
//

import SwiftUI

struct RandomListOptionsMenu: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @ObservedObject var model: RandomStoryListViewModel
    
    // list limit and reminders aren't important to be menu, leaving in options sheet
    @State private var showUnimportant = false
    
    var body: some View {
        Section(header: Text("View")) {
            MyButton(title:"Random Story", icon: "wand.and.stars", action: { model.getRandomStory(hasHapticsAndAnimation: false) })
        }
        
        /// reset filter by tag(s)
        if model.listOptions.isTagFilterActive {
            Section {
                MyButton(title: "Reset Tags", icon: "tag.slash.fill", action: model.resetTags)
            }
        }
        
        if showUnimportant {
            Section {
                /// list limit
                MyButton(title: model.listOptions.isListLimited ? "Reset List Limit": "Set last Limit (\(model.listOptions.listLimit))", icon: model.listOptions.isListLimited ? "infinity" : "arrow.up.and.down") {
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
            
            if showUnimportant {
                /// toggle sort order
                MyButton(title: "Sort \(model.listOptions.sortOrder.areInIncreasingOrder ? "Descending": "Ascending")", icon: model.listOptions.sortOrder.areInIncreasingOrder ? "textformat" : "textformat.size") {
                    model.listOptions.sortOrder.areInIncreasingOrder.toggle()
                }
            }
            
            Picker("SortOrder", selection: $model.listOptions.sortOrder) {
                ForEach(ListOptions.SortOrder.allCases) { order in
                    order.label().tag(order)
                }
            }
        }
        
        Section {
            MyButton(title: "Show Options", icon: "slider.horizontal.3", action: model.showListOptions)
        }
    }
}

struct RandomListOptionsMenu_Previews: PreviewProvider {
    @State static var context = SampleData.preview.container.viewContext
    
    static var previews: some View {
        NavigationView {
            List {
                RandomListOptionsMenu(model: RandomStoryListViewModel(context: context))
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
        }
        .previewLayout(.fixed(width: 350, height: 700))
        .environment(\.sizeCategory, .extraLarge)
        .environment(\.managedObjectContext, context)
        .environmentObject(Filter())
        .environmentObject(EventStore())
    }
}
