//
//  OLDListOptionsMenu.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 01.12.2020.
//

import SwiftUI

struct OLDListOptionsMenu: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @EnvironmentObject private var filter: Filter
    
    @State private var showingListOptions = false
    
    var body: some View {
        Menu {
            OLDListOptionsMenuInternals(filter: filter, showingListOptions: $showingListOptions)
        } label: {
            Image(systemName: "slider.horizontal.3")
        }
        .accentColor(filter.isActive ? Color(UIColor.systemOrange) : Color(UIColor.systemBlue))
        .sheet(isPresented: $showingListOptions) {
            OLDListFilterOptionView()
                .environment(\.managedObjectContext, context)
                .environmentObject(filter)
        }
    }
}

fileprivate struct OLDListOptionsMenuInternals: View {
    
    @ObservedObject var filter: Filter
    
    @Binding var showingListOptions: Bool
    
    var body: some View {
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
                    ForEach(Filter.RemindersFilterOptions.allCases) { option in
                        option.label().tag(option)
                    }
                }
            } label: {
                Label(filter.remindersFilter.rawValue, systemImage: "chevron.right")
            }
        }
        
        Section {
            Menu {
                Picker("Favorites", selection: $filter.favoritesFilter) {
                    ForEach(Filter.FavoritesFilterOptions.allCases) { option in
                        option.label().tag(option)
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
            ForEach(Filter.SortByOptions.allCases) { option in
                option.label().tag(option)
            }
        }
    }
    
    private func showOptionsButton() -> some View {
        Button {
            Ory.withHapticsAndAnimation {
                showingListOptions = true
            }
        } label: {
            Label("List Options", systemImage: "slider.horizontal.3")
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
                filter.sortOrder.areInIncreasingOrder.toggle()
            }
        } label: {
            Label("Sort \(filter.sortOrder.areInIncreasingOrder ? "Descending": "Ascending")", systemImage: filter.sortOrder.areInIncreasingOrder ? "textformat" : "textformat.size")
        }
    }
}

struct OLDListOptionsMenu_Previews: PreviewProvider {
    @State static private var showingListOptions = false
    
    static var previews: some View {
        Group {
            List {
                OLDListOptionsMenuInternals(filter: Filter(), showingListOptions: $showingListOptions)
            }
            .listStyle(InsetGroupedListStyle())
            .previewLayout(.fixed(width: 350, height: 500))
            
            VStack {
                OLDListOptionsMenu()
                    .padding()
                Spacer()
            }
            .previewLayout(.fixed(width: 350, height: 200))
        }
        .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
        .environmentObject(Filter())
        .preferredColorScheme(.dark)
        .previewLayout(.fixed(width: 350, height: 800))
    }
}
