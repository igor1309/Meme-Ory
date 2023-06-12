//
//  ContentView.swift
//  SingleStoryComponentPreview
//
//  Created by Igor Malyarov on 12.06.2023.
//

import SingleStoryComponent
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
