//
//  SearchListRowView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 23.11.2020.
//

import SwiftUI

/// to use in List
struct SearchListRowView: View {
    
    let title: String
    @Binding var text: String
    
    var body: some View {
        SearchView(title: title, text: $text)
            .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
    }
}


struct SearchRowView_Previews: PreviewProvider {
    @State static private var text = ""
    
    static var previews: some View {
        NavigationView {
            List {
                SearchListRowView(title: "type anything here", text: $text)
            }
            .listStyle((InsetGroupedListStyle()))
        }
        .environment(\.colorScheme, .dark)
    }
}
