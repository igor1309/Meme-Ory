//
//  StoryImporterModel.swift
//  
//
//  Created by Igor Malyarov on 08.07.2023.
//

import Combine
import Foundation

final class StoryImporterModel: ObservableObject {
    
    @Published private(set) var state: State?
    
    private let stateSubject = PassthroughSubject<State?, Never>()
    private let getTexts: (URL) throws -> [String]
    
    init(
        state: State? = nil,
        getTexts: @escaping (URL) throws -> [String]
    ) {
        self.state = state
        self.getTexts = getTexts
        
        stateSubject
            .receive(on: DispatchQueue.main)
            .assign(to: &$state)
    }
    
    func setState(to wrapper: State.TextsWrapper?) {
        guard let texts = wrapper?.texts else { return }
        stateSubject.send(.texts(texts))
    }
    
    func setState(to alert: State.AlertWrapper?) {
        guard let alert else { return }
        stateSubject.send(.alert(alert))
    }
    
    enum State {
        case texts([String])
        case alert(AlertWrapper)
        
        var texts: TextsWrapper? {
            guard case let .texts(texts) = self else { return nil }
            
            return .init(texts: texts)
        }
        
        var alert: AlertWrapper? {
            guard case let .alert(alert) = self else { return nil }
            
            return alert
        }
        
        struct TextsWrapper: Identifiable {
            let texts: [String]
            var id: Int { texts.hashValue }
        }
        
        struct AlertWrapper: Identifiable & Hashable {
            let message: String
            
            var id: Self { self }
        }
    }
    
    //  MARK: - Handle Open URL
    
//    func handleOpenURL(url: URL) {
//        switch url.deeplink {
//        case let .file(url: fileURL):
//            handleURLResult(.success(fileURL))
//            
//        default:
//            handleError("Can't process your request.\nSorry about that")
//        }
//    }
    
    //  MARK: - Handle File Importer
    
    func handleURLResult(_ result: Result<URL, Error>) {
        do {
            stateSubject.send(.texts(try getTexts(result.get())))
        } catch {
            handleError(error.localizedDescription)
        }
    }
    
    private func handleError(_ message: String) {
        stateSubject.send(.alert(.init(message: message)))
    }
}
