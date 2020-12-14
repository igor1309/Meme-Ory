//
//  TimestampPicker.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SwiftUI

struct TimestampPicker: View {
    
    @ObservedObject var model: MaintenanceViewModel
    
    var body: some View {
        Picker(selection: $model.selectedTimestampDate, label: label()) {
            Text("All Dates").tag(Date?.none)
            ForEach(model.timestampDuplicates) { (timestamp: TimestampDuplicate?) in
                Label("\(timestamp?.date ?? .distantPast, formatter: shorterFormatter)", systemImage: "\(timestamp?.count ?? 0).circle")
                    .tag(timestamp?.date)
            }
        }
        .pickerStyle(MenuPickerStyle())
    }
    private func label() -> some View {
        Group {
            if let date = model.selectedTimestampDate {
                Label("\(date, formatter: mediumFormatter)", systemImage: "calendar.badge.clock")
            } else {
                Label("Select Date to filter Stories", systemImage: "calendar.badge.clock")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
    }
}

fileprivate let mediumFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .medium
    return formatter
}()

fileprivate let shorterFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd.MM.yyyy HH:mm"
    //        formatter.dateStyle = .medium
    //        formatter.timeStyle = .short
    return formatter
}()


struct TimestampPicker_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            TimestampPicker(model: MaintenanceViewModel(context: SampleData.preview.container.viewContext))
        }
        .environment(\.colorScheme, .dark)
    }
}
