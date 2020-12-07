//
//  ListOptionsMenu.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 01.12.2020.
//

import SwiftUI

struct ListOptionsMenu: View {
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var filter: Filter
    
    @State private var showingListOptions = false
    
    var body: some View {
        Menu {
            Section {
                showOptionsButton()
            }
            /// reset filter by tag(s)
            resetFilterByTagSection()
            /// list limit
            Section {
                listLimitButton()
            }
            Section {
                Menu {
                    Picker("Reminders", selection: $filter.remindersFilter) {
                        ForEach(Filter.RemindersFilterOptions.allCases, id: \.self) { option in
                            Label(option.rawValue, systemImage: option.icon)
                                .tag(option)
                        }
                    }
                } label: {
                    Label(filter.remindersFilter.rawValue, systemImage: "chevron.right")
                }
            }
            Section {
                Menu {
                    Picker("Favorites", selection: $filter.favoritesFilter) {
                        ForEach(Filter.FavoritesFilterOptions.allCases, id: \.self) { option in
                            Label(option.rawValue, systemImage: option.icon)
                                .tag(option)
                        }
                    }
                } label: {
                    Label(filter.favoritesFilter.rawValue, systemImage: "chevron.right")
                }
            }
            /// toggle sort order
            sortOrderButton()
            /// change item to sort by
            Picker("Sort by", selection: $filter.itemToSortBy) {
                ForEach(Filter.SortByOptions.allCases, id: \.self) { option in
                    Label(option.rawValue, systemImage: option.icon)
                        .tag(option)
                }
            }
            //changeItemToSortByButton()
            /// set list limit (number of stories showing)
        } label: {
            Image(systemName: "slider.horizontal.3")
                .labelStyle(IconOnlyLabelStyle())
        }
        .accentColor(filter.isActive ? Color(UIColor.systemOrange) : Color(UIColor.systemBlue))
        .sheet(isPresented: $showingListOptions) {
            ListOptionView()
                .environment(\.managedObjectContext, context)
                .environmentObject(filter)
        }
    }
    private func showOptionsButton() -> some View {
        Button {
            Ory.withHapticsAndAnimation {
                showingListOptions = true
            }
        } label: {
            Label("List Options", systemImage: "slider.horizontal.3")
                .padding([.vertical, .trailing])
        }
    }
    
    @ViewBuilder
    private func resetFilterByTagSection() -> some View {
        if filter.isTagFilterActive {
            Section {
                Button {
                    Ory.withHapticsAndAnimation {
                        filter.resetTags()
                    }
                } label: {
                    Label("Reset Tags", systemImage: "tag.slash.fill")
                }
            }
        } else {
            EmptyView()
        }
    }
    
    private func listLimitButton() -> some View {
        Button {
            Ory.withHapticsAndAnimation {
                filter.isListLimited.toggle()
            }
        } label: {
            Label(filter.isListLimited ? "Reset List Limit": "Set last Limit (\(filter.listLimit))",
                  systemImage: filter.isListLimited ? "infinity" : "arrow.up.and.down")
        }
    }
    
    private func sortOrderButton() -> some View {
        Button {
            Ory.withHapticsAndAnimation {
                filter.areInIncreasingOrder.toggle()
            }
        } label: {
            Label("Sort \(filter.areInIncreasingOrder ? "Descending": "Ascending")", systemImage: filter.areInIncreasingOrder ? "textformat" : "textformat.size")
        }
    }
}

struct ListOptionsMenu_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ListOptionsMenu()
                .padding()
            Spacer()
        }
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .environmentObject(Filter())
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 350, height: 800))
    }
}
