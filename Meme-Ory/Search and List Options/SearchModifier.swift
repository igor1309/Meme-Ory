//
//  SearchModifier.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 23.11.2020.
//

import SwiftUI

extension View {
    func searchModifier(text: Binding<String>) -> some View {
        self.modifier(SearchModifier(text: text))
    }
}

fileprivate struct SearchModifier: ViewModifier {
    
    @Binding var text: String
    
    func body(content: Content) -> some View {
        HStack(alignment: .center, spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            //TextField(title, text: $text)
            content
            
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

fileprivate struct SearchModifier_Testing: View {
    @State private var text = ""
    
    var body: some View {
        Group {
            NavigationView {
                VStack {
                    TextField("type anything here", text: $text)
                        .searchModifier(text: $text)
                    
                    TextField("type anything here", text: $text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .searchModifier(text: $text)
                }
                .padding()
                .navigationBarTitle("SearchModifier: in Stack (not List)", displayMode: .inline)
            }
            .previewLayout(.fixed(width: 350, height: 300))
            
            NavigationView {
                List {
                    Section(header: Text("no row insets")) {
                        TextField("type anything here", text: $text)
                            .searchModifier(text: $text)
                    }
                    
                    Section(
                        header: Text("with row insets"),
                        footer: Text("mind row insets!").foregroundColor(.red)
                    ) {
                        TextField("type anything here", text: $text)
                            .searchModifier(text: $text)
                            .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
                    }
                }
                .listStyle((InsetGroupedListStyle()))
                .navigationBarTitle("SearchModifier: in List", displayMode: .inline)
            }
            .previewLayout(.fixed(width: 350, height: 350))
        }
    }
}

struct SearchModifier_Previews: PreviewProvider {
    @State static private var text = ""
    
    static var previews: some View {
        SearchModifier_Testing()
            .environment(\.colorScheme, .dark)
    }
}
