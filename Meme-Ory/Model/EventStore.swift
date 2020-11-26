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
    
    init() {
        accessGranted = false
        
        EKEventStore()
            .currentAuthorizationStatus()
            .receive(on: DispatchQueue.main)
            // .assign(to: \.accessGranted, on: self)
            .sink { [weak self] in
                self?.accessGranted = $0
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
}
