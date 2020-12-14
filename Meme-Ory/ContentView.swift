//
//  ContentView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 29.11.2020.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    
    var body: some View {
        MainViewWrapper()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environment(\.managedObjectContext, SampleData.preview.container.viewContext)
            .environmentObject(EventStore())
            .environmentObject(Filter())
            .preferredColorScheme(.dark)
            .previewLayout(.fixed(width: 350, height: 800))
    }
}
