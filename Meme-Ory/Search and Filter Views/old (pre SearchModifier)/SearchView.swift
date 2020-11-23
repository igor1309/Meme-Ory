//
//  SearchView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 22.11.2020.
//

import SwiftUI

struct SearchView: View {
    
    let title: String
    @Binding var text: String
    
    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField(title, text: $text)
            
            Button {
                withAnimation {
                    text = ""
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color(UIColor.tertiaryLabel))
                    .opacity(text.isEmpty ? 0 : 1)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    @State static private var text = ""
    
    static var previews: some View {
        Group {
            NavigationView {
                VStack {
                    SearchView(title: "type anything here", text: $text)
                }
                .navigationTitle("Stack (not List)")
            }
            .previewLayout(.fixed(width: 350, height: 300))
            
            NavigationView {
                List {
                    Section(header: Text("Search View")) {
                        SearchView(title: "type anything here", text: $text)
                    }
                    
                    Section(
                        header: Text("Search List Row View"),
                        footer: Text("mind row insets in SearchListRowView!").foregroundColor(.red)
                    ) {
                        SearchListRowView(title: "type anything here", text: $text)
                    }
                }
                .listStyle((InsetGroupedListStyle()))
                .navigationTitle("List")
            }
            .previewLayout(.fixed(width: 350, height: 350))
        }
        .environment(\.colorScheme, .dark)
    }
}
