//
//  MaintenanceViewModel.swift
//  Meme-Ory
//
//  Created by Igor Malyarov on 14.12.2020.
//

import SwiftUI
import CoreData
import Combine

final class MaintenanceViewModel: ObservableObject {
    
    @Published var selectedTimestampDate: Date?
    @Published var timestampDuplicates = [TimestampDuplicate]()
    
    @Published var selectedText: String?
    @Published var textDuplicates = [TextDuplicate]()
    
    let context: NSManagedObjectContext
    let markDeleteTag: Tag
    var hasTimestampDate: Bool { selectedTimestampDate != nil }
    
    
    //  MARK: - Init & Subscribe
    
    init(context: NSManagedObjectContext) {
        self.context = context
        
        let markDeleteTagName = "##deleteThis##"
        self.markDeleteTag = context.getTag(withName: markDeleteTagName)
        
        timestampDuplicates = fetchTimestampDuplicates(countMin: 2)
        textDuplicates = fetchTextDuplicates(countMin: 2)
        
        subscribe()
    }
    
    /// subscribe to changes in context
    private func subscribe() {
        
        // update timestampDuplicates & timestampDate
        context.didSavePublisher
            .delay(for: 0.5, scheduler: DispatchQueue.global())
            .flatMap { _ in
                Just(self.fetchTimestampDuplicates(countMin: 2))
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (timestampDuplicates: [TimestampDuplicate]) in
                self?.timestampDuplicates = timestampDuplicates
                // nullify if timestampDate refers to date not present in timestampDuplicates
                if let timestampDate = self?.selectedTimestampDate,
                   !timestampDuplicates.map(\.date).contains(timestampDate) {
                    self?.selectedTimestampDate = nil
                }
            }
            .store(in: &cancellableSet)
        
        // update textDuplicates & selectedText
        context.didSavePublisher
            .flatMap { _ in
                Just(self.fetchTextDuplicates(countMin: 2))
            }
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (textDuplicates: [TextDuplicate]) in
                self?.textDuplicates = textDuplicates
                // nullify if selectedText refers to text not present in textDuplicates
                if let selectedText = self?.selectedText,
                   !textDuplicates.map(\.text).contains(selectedText) {
                    self?.selectedText = nil
                }
            }
            .store(in: &cancellableSet)
        
    }
    
    private var cancellableSet = Set<AnyCancellable>()
    
    deinit {
        for cancell in cancellableSet {
            cancell.cancel()
        }
    }
    
    
    //  MARK: - Fetch & Transform
    
    private func fetchTimestampDuplicates(countMin: Int = 2) -> [TimestampDuplicate] {
        returnFetch(keyPath: \Story.timestamp_, countMin: countMin, transform: transform)
    }
    
    private func fetchTextDuplicates(countMin: Int = 2) -> [TextDuplicate]{
        returnFetch(keyPath: \Story.text_, countMin: countMin, transform: transform)
    }
    
    private func transform(_ dic: NSDictionary) -> TimestampDuplicate? {
        guard let count = dic["count"] as? Int,
              let date = dic["timestamp_"] as? Date else { return nil }
        
        return TimestampDuplicate(date: date, count: count)
    }
    
    private func transform(_ dic: NSDictionary) -> TextDuplicate? {
        guard let count = dic["count"] as? Int,
              let text = dic["text_"] as? String else { return nil }
        
        return TextDuplicate(text: text, count: count)
    }
    
    private func returnFetch<T, Value>(keyPath: KeyPath<Story, Value>, countMin: Int = 2, transform: (NSDictionary) -> T?) -> [T] {
        
        // https://stackoverflow.com/a/38150048/11793043
        // https://stackoverflow.com/a/38313716/11793043
        
        let keyPathString = NSExpression(forKeyPath: keyPath).keyPath
        
        // print("running generic returnFetch @ MaintenanceViewModel for \(keyPathString)")
        
        let attributeExpression = NSExpression(forKeyPath: keyPathString)
        
        let count = NSExpressionDescription()
        count.name = "count"
        count.expression = NSExpression(forFunction: "count:", arguments: [attributeExpression])
        count.expressionResultType = .integer64AttributeType
        
        let countExpression = NSExpression(forVariable: "count")
        
        let request = NSFetchRequest<NSDictionary>()
        request.entity = Story.entity()
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [keyPathString, count]
        request.propertiesToGroupBy = [keyPathString]
        request.returnsDistinctResults = true
        request.havingPredicate = NSComparisonPredicate(
            leftExpression: countExpression,
            rightExpression: NSExpression(forConstantValue: countMin),
            modifier: NSComparisonPredicate.Modifier.direct,
            type: NSComparisonPredicate.Operator.greaterThanOrEqualTo,
            options: [])
        
        let sortDescriptor = NSSortDescriptor(keyPath: keyPath, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        guard let fetch = try? context.fetch(request) else { return [] }
        
        let result = fetch.compactMap(transform)
        return result
    }
    
}


//  MARK: - Maintenance View Model extension
extension MaintenanceViewModel {
    private func fetchTimestampDuplicates(countMin: Int = 2) {
        fetch(keyPath: \Story.timestamp_, countMin: countMin, transform: transform) {
            self.timestampDuplicates = $0
        }
    }
    
    private func fetchTextDuplicates(countMin: Int = 2) {
        fetch(keyPath: \Story.text_, countMin: countMin, transform: transform) {
            self.textDuplicates = $0
        }
    }
    
    private func fetch<T, Value>(
        keyPath: KeyPath<Story, Value>,
        countMin: Int = 2,
        transform: (NSDictionary) -> T?,
        completion: @escaping ([T]) -> Void
    ) {
        let keyPathString = NSExpression(forKeyPath: keyPath).keyPath
        
        print("running generic fetch @ MaintenanceViewModel for \(keyPathString)")
        
        let attributeExpression = NSExpression(forKeyPath: keyPathString)
        
        let count = NSExpressionDescription()
        count.name = "count"
        count.expression = NSExpression(forFunction: "count:", arguments: [attributeExpression])
        count.expressionResultType = .integer64AttributeType
        
        let countExpression = NSExpression(forVariable: "count")
        
        let request = NSFetchRequest<NSDictionary>()
        request.entity = Story.entity()
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [keyPathString, count]
        request.propertiesToGroupBy = [keyPathString]
        request.returnsDistinctResults = true
        // https://stackoverflow.com/a/38150048/11793043
        request.havingPredicate = NSComparisonPredicate(
            leftExpression: countExpression,
            rightExpression: NSExpression(forConstantValue: countMin),
            modifier: NSComparisonPredicate.Modifier.direct,
            type: NSComparisonPredicate.Operator.greaterThanOrEqualTo,
            options: [])
        
        
        let sortDescriptor = NSSortDescriptor(keyPath: keyPath, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        guard let fetch = try? context.fetch(request) else { return }
        
        let result = fetch.compactMap(transform)
        completion(result)
    }
    
}

//  MARK: - Original Non-generic fetch as reference
private extension MaintenanceViewModel {
    
    /// Just a backup `not for use`
    private func nonGenericFetch() {
        print("running fetch @ MaintenanceViewModel")
        
        let timestampKeyPath = #keyPath(Story.timestamp_)
        let timestampExpression = NSExpression(forKeyPath: timestampKeyPath)
        
        let count = NSExpressionDescription()
        count.name = "count"
        count.expression = NSExpression(forFunction: "count:", arguments: [timestampExpression])
        count.expressionResultType = .integer64AttributeType
        
        let countExpression = NSExpression(forVariable: "count")
        
        let request = NSFetchRequest<NSDictionary>()
        request.entity = Story.entity()
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = [timestampKeyPath, count]
        request.propertiesToGroupBy = [timestampKeyPath]
        request.returnsDistinctResults = true
        request.havingPredicate = NSPredicate(format: "%@ >= 1", countExpression)
        
        let sortDescriptor = NSSortDescriptor(keyPath: \Story.timestamp_, ascending: false)
        request.sortDescriptors = [sortDescriptor]
        
        guard let fetch = try? context.fetch(request) else { return }
        
        timestampDuplicates = fetch.compactMap { dic -> TimestampDuplicate? in
            guard let count = dic["count"] as? Int,
                  let date = dic["timestamp_"] as? Date else { return nil }
            
            return TimestampDuplicate(date: date, count: count)
        }
    }
    
    
}

