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
        
        textView.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)
        
        navigationItem.title = "New Story"

        
        // fixing keyboard
        // https://www.hackingwithswift.com/read/19/7/fixing-the-keyboard-notificationcenter
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.setLeftBarButton(cancelButton, animated: true)
        
        let saveButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        saveButton.style = .done
        navigationItem.setRightBarButton(saveButton, animated: true)
        
        
        //  MARK: Handling Extension Context
        //
        guard let item = self.extensionContext?.inputItems.first as? NSExtensionItem,
              let provider = item.attachments?.first else { return }
        
        // text
        if provider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
            weak var weakTextView = self.textView
            provider.loadItem(forTypeIdentifier: kUTTypeText as String) { (result, error) in
                DispatchQueue.main.async {
                    if let strongTextView = weakTextView {
                        if let text = result as? String {
                            strongTextView.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                    }
                }
            }
        }
        
        // from web
        // https://www.hackingwithswift.com/read/19/5/establishing-communication
        if provider.hasItemConformingToTypeIdentifier(kUTTypePropertyList as String) {
            weak var weakTextView = self.textView
            provider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { (result, error) in
                guard let itemDictionary = result as? NSDictionary else { return }
                guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }
                
                let pageTitle = javaScriptValues["title"] as? String ?? ""
                let pageURL = javaScriptValues["URL"] as? String ?? ""
                let pageBody = javaScriptValues["body"] as? String ?? ""
                let text = "\(pageTitle)\n\(pageURL)\n\n\(pageBody)".trimmingCharacters(in: .whitespacesAndNewlines)
                
                DispatchQueue.main.async {
                    if let strongTextView = weakTextView {
                        strongTextView.text = text
                    }
                }
            }
        }
    }
    
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            textView.contentInset = .zero
        } else {
            textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        textView.scrollIndicatorInsets = textView.contentInset
        
        let selectedRange = textView.selectedRange
        textView.scrollRangeToVisible(selectedRange)
    }
    
    
    @IBAction func cancel() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    @IBAction func save() {
        
        //  MARK: save Story
        //
        let storageProvider = StorageProvider()
        let context = storageProvider.container.viewContext
        
        let story = Story(context: context)
        story.text_ = textView.text
        story.timestamp_ = Date()
        
        context.saveContext()
        
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
        
        Ory.feedback(type: .success)
    }
}
