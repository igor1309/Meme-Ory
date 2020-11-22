//
//  SearchView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

struct SearchView: View {
    
    @Binding var filter: Filter
    
    var body: some View {
        TextField("Filter", text: $filter.string)
    }
}

struct SearchView_Testing: View {
    
    @State private var filter: Filter = Filter()
    
    var body: some View {
        SearchView(filter: $filter)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            List {
                SearchView_Testing()
            }
            .listStyle((InsetGroupedListStyle()))
        }
        .environment(\.colorScheme, .dark)
    }
}
