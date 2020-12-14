//
//  SwiftUIView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SwiftUI

extension View {
    func confirmAndDelete<Item: Identifiable>(_ item: Binding<Item?>, title: String = "Delete?", deleteAction: @escaping (Item) -> Void) -> some View {
        self
            .modifier(ConfirmAndDelete(item, title: title, deleteAction: deleteAction))
    }
}

fileprivate struct ConfirmAndDelete<Item: Identifiable>: ViewModifier {
    
    let title: String
    @Binding var item: Item?
    let deleteAction: (Item) -> Void
    
    init(_ item: Binding<Item?>, title: String?, deleteAction: @escaping (Item) -> Void) {
        _item = item
        self.title = title ?? "Delete?"
        self.deleteAction = deleteAction
    }
    
    func body(content: Content) -> some View {
        content
            .actionSheet(item: $item, content: actionSheet)
    }
    
    private func actionSheet(_ value: Item) -> ActionSheet {
        ActionSheet(
            title: Text(title),
            message: Text("Are you sure? This cannot be undone."),
            buttons: [
                .destructive(Text("Yes, delete!")) { deleteAction(value) },
                .cancel()
            ]
        )
    }
}

struct ConfirmAndDelete_Testing: View {
    @State private var actionID: ActionID?
    
    enum ActionID: String, Identifiable {
        case go
        var id: Int { hashValue }
    }
    
    @State private var test = "test"
    
    var body: some View {
        Button(test) {
            actionID = .go
        }
        .confirmAndDelete($actionID, title: "Testing".uppercased()) { action in
            print("\(action.rawValue)!")
            self.test = action.rawValue
        }
    }
}

struct ConfirmAndDelete_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmAndDelete_Testing()
    }
}
