//
//  ImportTextViewModel.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 27.11.2020.
//

import Foundation

final class ImportTextViewModel: ObservableObject {
    @Published var briefs: [Brief]
    
    init(url: URL) {
        let texts = url.getTexts()
        
        if texts.isEmpty {
            briefs = url.getBriefs()
        }
        
        briefs = texts.map {
            Brief(text: $0)
        }
    }
    
    init(texts: [String]) {
        briefs = texts.map {
            Brief(text: $0)
        }
    }
    
    var count: Int {
        briefs.count
    }
    
    var selectedBriefs: [Brief] {
        briefs.filter { $0.check }
    }
    
    var selectedCount: Int {
        briefs.filter { $0.check }.count
    }
    
    func toggleCheck(for brief: Brief) {
        if let index = briefs.firstIndex(where: { $0.text == brief.text }) {
            briefs[index].check.toggle()
        }
    }
}

