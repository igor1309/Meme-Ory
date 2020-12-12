//
//  ImportTextViewModel.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 27.11.2020.
//

import Foundation

final class ImportTextViewModel: ObservableObject {
    
    @Published var briefs: [Brief]
    @Published private(set) var string: String
    
    init(url: URL) {
        #if DEBUG
        print("ImportTextViewModel.init: ...")
        #endif
        
        let texts = url.getTexts()
        
        briefs = texts.map {
            Brief(text: $0)
        }
        
        string = (try? String(contentsOf: url)) ?? ""
        
        #if DEBUG
        print("ImportTextViewModel.init: \((briefs.first ?? Brief(text: "NO BRIEFS")).text.prefix(20))")
        #endif
    }
    
    init(texts: [String]) {
        #if DEBUG
        print("ImportTextViewModel.init: ...")
        #endif
        
        briefs = texts.map {
            Brief(text: $0)
        }
        string = texts.joined(separator: "\n")
        
        #if DEBUG
        print("ImportTextViewModel.init: \((texts.first ?? "NO BRIEFS").prefix(20))")
        #endif
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

