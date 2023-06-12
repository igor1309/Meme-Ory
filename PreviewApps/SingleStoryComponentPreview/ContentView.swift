//
//  ContentView.swift
//  SingleStoryComponentPreview
//
//  Created by Igor Malyarov on 12.06.2023.
//

import SingleStoryComponent
import SwiftUI

struct ContentView: View {
    
    let text: String = .preview
    
    @State private var maxTextLength: Int?
    
    private let maxLengths: [Int?] = [10, 100, nil]
    
    var body: some View {
        VStack(spacing: 16) {
            
            Picker("Max Text Length", selection: $maxTextLength) {
                ForEach(maxLengths, id: \.self) { maxTextLength in
                    if let maxTextLength {
                        Text(maxTextLength.formatted())
                        .tag(maxTextLength)
                    } else {
                        Text("none")
                        .tag(Int?.none)
                    }
                }
            }
            .pickerStyle(.segmented)
            
            SingleStoryToolbar(
                isFavorite: true,
                hasReminder: true,
                switchViewMode: {}
            )
            
            SingleStoryView(
                text: .preview,
                maxTextLength: maxTextLength
            )
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension String {
    
    static let preview: Self = """
        — А что у тебя с тем Борей?
        — Ой, я того Борю… убила бы!
        — А что такое?
        — Пригласила его в гости, тонко попросила купить в ближайшей аптеке "что–нибудь к чаю"... И так, что вы думаете принес—этот поц?
        — Хаааа... А есть ещё варианты?!
        — Есть! Он, бл@дь, припёр "Гематоген"!
        """
}
