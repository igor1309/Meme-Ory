//
//  SearchView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

struct SearchView: View {
    
    @Binding var searchString: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Filter (at least 3 letters)", text: $searchString)
            
            Button {
                withAnimation {
                    searchString = ""
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                    .opacity(searchString.isEmpty ? 0 : 1)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
    }
}

struct SearchView_Previews: PreviewProvider {
    @State static private var searchString = ""
    
    static var previews: some View {
        NavigationView {
            List {
                SearchView(searchString: $searchString)
            }
            .listStyle((InsetGroupedListStyle()))
        }
        .environment(\.colorScheme, .dark)
    }
}
