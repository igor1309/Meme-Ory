//
//  Ext+EKEventStore.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 26.11.2020.
//

import Combine
import EventKit

extension EKEventStore {
    typealias AuthorizationStatusPublisher = AnyPublisher<Bool, Never>
    
    func currentAuthorizationStatus() -> AuthorizationStatusPublisher {
        Deferred {
            Future { [unowned self] promise in
                requestAccess(to: .reminder) { granted, error in
                    promise(.success(granted))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}


