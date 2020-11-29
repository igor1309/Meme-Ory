//
//  EventStore.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 26.11.2020.
//

import Combine
import EventKit

final class EventStore: ObservableObject {
    @Published var accessGranted: Bool
    
    private let store = EKEventStore()
    
    static let components: [Calendar.Component] = [.day, .weekOfYear, .month, .year]
    
    init() {
        accessGranted = false
        
        EKEventStore()
            .currentAuthorizationStatus()
            .receive(on: DispatchQueue.main)
            // .assign(to: \.accessGranted, on: self)
            .sink { [weak self] in
                print("EKEventStore access checked in subscription. Access \($0 ? "granted" : "denied").")
                self?.accessGranted = $0
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    //  MARK: - FINISH THIS
    // func calendarItem(withIdentifier identifier: String) -> EKCalendarItem?
    // Returns either the event’s first occurrence or the reminder with the specified identifier.
    //  MARK: -
    
    
}

extension EventStore {
    typealias CalendarItemIdentifier = String
    
    func reminder(for story: Story) -> EKReminder? {
        accessGranted ? store.calendarItem(withIdentifier: story.calendarItemIdentifier) as? EKReminder : nil
    }
    
    func hasReminder(with calendarItemIdentifier: CalendarItemIdentifier) -> Bool {
        if accessGranted,
           let _ = store.calendarItem(withIdentifier: calendarItemIdentifier) {
            return true
        } else {
            return false
        }
    }
    
    //  MARK: - FINISH THIS
    // next month: next month 1st day
    // next weeek: next monday
    // next year: next Jan 1
    //
    func addReminder(for story: Story, component: Calendar.Component, hour: Int = 9) -> CalendarItemIdentifier? {
        
        //let store = EKEventStore()
        
        //  MARK: - FINISH THIS
        //  add option to select calendar?
        //  https://nemecek.be/blog/16/how-to-use-ekcalendarchooser-in-swift-to-let-user-select-calendar-in-ios
        //
        guard let ekCalendar = store.defaultCalendarForNewReminders() else {
            print("Error getting default calendar for new reminders")
            return nil
        }
        
        var nextComponent = DateComponents()
        nextComponent.setValue(1, for: component)
        
        let calendar = Calendar(identifier: .gregorian)
        let nextDate = calendar.date(byAdding: nextComponent, to: Date())!
        var nextComponents = Calendar.current.dateComponents(Set(EventStore.components), from: nextDate)
        nextComponents.hour = hour
        
        let newReminder = EKReminder(eventStore: store)
        newReminder.calendar = ekCalendar
        newReminder.title = story.text
        newReminder.dueDateComponents = nextComponents
        
        // let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        // newReminder.notes = "created by \(appName)"
        
        //  MARK: setting url property has no effect, it's a known bug
        //  https://developer.apple.com/forums/thread/128140
        newReminder.url = story.url
        //  that's why write to notes
        newReminder.notes = story.url.absoluteString
        
        // delete existing reminder first - only one reminder ccould be tracked
        // otherwise can't track reminders from stories
        if let reminder: EKReminder = store.calendarItem(withIdentifier: story.calendarItemIdentifier) as? EKReminder {
            do {
                try store.remove(reminder, commit: true)
            } catch let error as NSError {
                print("Error deleting reminder referenced in story\n\(error.localizedDescription)")
            }
        }
        
        do {
            try store.save(newReminder, commit: true)
            return newReminder.calendarItemIdentifier
        } catch let error as NSError {
            print("Error saving reminder:\n\(error.localizedDescription)")
            return nil
        }
    }
}
