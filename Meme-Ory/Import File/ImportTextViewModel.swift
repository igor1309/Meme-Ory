//
//  ImportTextViewModel.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 27.11.2020.
//

import Foundation

final class ImportTextViewModel: ObservableObject {
    @Published var briefs: [Brief]
    
    var selectedBriefs: [Brief] {
        briefs.filter { $0.check }
    }
    
    var count: Int {
        briefs.count
    }
    var selectedCount: Int {
        briefs.filter { $0.check }.count
    }
    
    init(url: URL) {
        let texts = url.getTexts()
        
        if texts.isEmpty {
            briefs = url.getBriefs()
        }
        
        briefs = texts.map {
            Brief(text: $0)
        }
    }
    
    init(briefs: [Brief]) {
        self.briefs = briefs
    }
    
    func toggleCheck(for brief: Brief) {
        if let index = briefs.firstIndex(where: { $0.text == brief.text }) {
            briefs[index].check.toggle()
        }
    }
}

