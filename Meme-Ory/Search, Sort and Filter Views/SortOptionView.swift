//
//  SortOptionView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 23.11.2020.
//

import SwiftUI

struct SortOptionView: View {
    
    @Environment(\.presentationMode) private var presentation
    
    @Binding var filter: Filter
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Sort")) {
                    Toggle(isOn: $filter.areInIncreasingOrder) {
                        Label {
                            VStack(alignment: .leading) {
                                Text("Ascending")
                                Text("Select sort order")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        } icon: {
                            Image(systemName: "arrow.up.arrow.down.square")
                                .imageScale(.large)
                                .offset(y: 6)
                        }
                    }
                    .accentColor(Color(UIColor.systemOrange))
                }
            }
            .navigationTitle("Sort Options")
            .navigationBarItems(trailing: doneButton())
        }
    }
    
    private func doneButton() -> some View {
        Button("Done") {
            presentation.wrappedValue.dismiss()
        }
    }
}

struct SortOptionView_Texting: View {
    @State var filter = Filter()
    
    var body: some View {
        SortOptionView(filter: $filter)
    }
}
struct SortOptionView_Previews: PreviewProvider {
    static var previews: some View {
        SortOptionView_Texting()
            .previewLayout(.fixed(width: 350, height: 400))
            .preferredColorScheme(.dark)
    }
}
