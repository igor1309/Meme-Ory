//
//  TestingLazyVStackView.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 07.12.2020.
//

import SwiftUI
import CoreData

struct TestingLazyVStackView: View {
    
    @Environment(\.managedObjectContext) private var context
    
    @StateObject private var model: RandomStoryListViewModel
    
    init(context: NSManagedObjectContext) {
        _model = StateObject(wrappedValue: RandomStoryListViewModel(context: context))
    }
    
    private var columns: [GridItem] = [.init(.flexible())]
    
    var body: some View {
        VStack {
            //  MARK: - FINISH THIS: MOVE TO FILTER
            HStack {
                Picker("# of stories", selection: $model.k) {
                    ForEach([5, 13, 25], id: \.self) { qty in
                        Text("\(qty)").tag(qty)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Button(action: model.update) {
                    Image(systemName: "wand.and.stars")
                        .cardModifier(padding: 6, cornerRadius: 6, strokeBorderColor: Color.clear, background: Color(UIColor.secondarySystemBackground))
                }
            }
            .padding()
            
            //MARK: - FINISH THIS: TESTING LazyVStack
            ScrollView {
                LazyVStack(alignment: .leading, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/, pinnedViews: /*@START_MENU_TOKEN@*/[]/*@END_MENU_TOKEN@*/, content: {
                    ForEach(model.stories) { story in
                        OLDStoryListRowView(story: story, lineLimit: nil)
                            .padding(.horizontal)
                    }
                })
            }
            
        }
        .listStyle(InsetGroupedListStyle())
        .onAppear(perform: model.update)
    }
}

struct TestingLazyVStackView_Previews: PreviewProvider {
    @State static var context = SampleData.preview.container.viewContext
    
    static var previews: some View {
        TestingLazyVStackView(context: context)
            .environment(\.managedObjectContext, context)
            .environmentObject(Filter())
            .environmentObject(EventStore())
            .environment(\.sizeCategory, .large)
            .preferredColorScheme(.dark)
    }
}
