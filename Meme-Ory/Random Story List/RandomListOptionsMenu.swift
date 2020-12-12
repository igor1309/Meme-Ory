//
//  RandomListOptionsMenu.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 08.12.2020.
//

import SwiftUI

extension RandomStoryListViewModel {
    var hasLineLimit: Bool {
        get { lineLimit != nil }
        set { lineLimit = newValue ? RandomStoryListViewModel.lineLimitConstant : nil }
    }
    
    private static let lineLimitConstant = 4
    
}

struct RandomListOptionsMenu: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject var model: RandomStoryListViewModel
    
    /// list limit and reminders aren't important to be menu, leaving them in options sheet
    @State private var showUnimportant = false
    
    var body: some View {
        #if DEBUG
        Section(header: Text("Debug")) {
            MyButton(title: "Test Context Notification", icon: "sparkles.rectangle.stack") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let story = Story(context: context)
                    story.text = "Test \(Date().description)"
                    story.timestamp = Date()
                    context.saveContext()
                }
            }
        }
        #endif
        
        Section(header: Text("Random")) {
            MyButton(title: "Shuffle List", icon: "wand.and.stars", action: model.update)
            #if DEBUG
            MyButton(title:"Random Story", icon: "wand.and.stars") { model.getRandomStory(hasHapticsAndAnimation: false)
            }
            #endif
        }
        
        Section(header: Text("View")) {
            Toggle(isOn: $model.hasLineLimit) {
                Label("Line Limit", systemImage: "rectangle.arrowtriangle.2.inward")
            }
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
                RandomListOptionsMenu()
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarTitleDisplayMode(.inline)
        }
        .previewLayout(.fixed(width: 350, height: 800))
        .environment(\.sizeCategory, .extraLarge)
        .environment(\.managedObjectContext, context)
        .environmentObject(RandomStoryListViewModel(context: context))
        .environmentObject(Filter())
        .environmentObject(EventStore())
    }
}
