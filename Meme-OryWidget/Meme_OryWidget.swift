//
//  Meme_OryWidget.swift
//  Meme-OryWidget
//
//  Created by Igor Malyarov on 24.11.2020.
//

import WidgetKit
import SwiftUI
import CoreData

@main
struct Meme_OryWidget: Widget {
    let kind: String = "Meme_OryWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}
