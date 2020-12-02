//
//  ActionViewController.swift
//  ShareExtension
//
//  Created by Igor Malyarov on 30.11.2020.
//

import UIKit
import MobileCoreServices

/// https://stackoverflow.com/questions/44994932/how-to-share-selected-text-with-my-application
class ActionViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        
        navigationItem.title = "New Story"
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.setLeftBarButton(cancelButton, animated: true)
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        saveButton.style = .done
        navigationItem.setRightBarButton(saveButton, animated: true)
        
        guard let item = self.extensionContext?.inputItems.first as? NSExtensionItem,
              let provider = item.attachments?.first else { return }
        
        // text
        if provider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
            weak var weakTextView = self.textView
            provider.loadItem(forTypeIdentifier: kUTTypeText as String) { (result, error) in
                DispatchQueue.main.async {
                    if let strongTextView = weakTextView {
                        if let text = result as? String {
                            strongTextView.text = text
                            //  MARK: - FINISH THIS
                            //
                        }
                    }
                }
            }
        }
        
        // from web
        if provider.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
            weak var weakTextView = self.textView
            provider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { (result, error) in
                guard let itemDictionary = result as? NSDictionary else { return }
                guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                
                let pageTitle = javaScriptValues["title"] as? String ?? ""
                let pageURL = javaScriptValues["URL"] as? String ?? ""
                
                DispatchQueue.main.async {
                    if let strongTextView = weakTextView {
                        strongTextView.text = "\(pageTitle)\n\(pageURL)"
                    }
                }
            }
        }
    }
    
    @IBAction func cancel() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    @IBAction func save() {
        
        //  MARK: save Story
        //
        let persistenceController = PersistenceController.shared
        let context = persistenceController.container.viewContext
        
        let story = Story(context: context)
        story.text_ = textView.text
        story.timestamp_ = Date()
        
        context.saveContext()
        
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        
        let haptics = Haptics()
        haptics.feedback(feedback: .success)
    }
}
