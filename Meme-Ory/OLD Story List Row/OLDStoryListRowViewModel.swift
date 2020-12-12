//
//  OLDStoryListRowViewModel.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 08.12.2020.
//

import SwiftUI
import CoreData

final class OLDStoryListRowViewModel: ObservableObject {
    
    @Published var actionSheetID: ActionSheetID?
    
    enum ActionSheetID: Identifiable {
        case remindMe
        var id: Int { hashValue }
    }
    
    @Published var sheetID: SheetID?
    
    enum SheetID: Identifiable {
        case edit
        var id: Int { hashValue }
    }
    
    
    //  MARK: Functions
    
    func remindMe() {
        actionSheetID = .remindMe
    }
    
    func editStory() {
        sheetID = .edit
    }

}
