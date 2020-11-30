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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
        
        if let item = self.extensionContext?.inputItems.first as? NSExtensionItem,
           let provider = item.attachments?.first,
           provider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
            weak var weakTextView = self.textView
            provider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil, completionHandler: { (result, error) in
                DispatchQueue.main.async {
                    if let strongTextView = weakTextView {
                        if let text = result as? String {
                            strongTextView.text = text
                            //  MARK: - FINISH THIS
                            //
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func save() {
        
        let returnProvider = NSItemProvider(item: textView.text as NSSecureCoding?,
                                            typeIdentifier: kUTTypeText as String)
        
        let returnItem = NSExtensionItem()
        
        returnItem.attachments = [returnProvider]
        self.extensionContext!.completeRequest(
            returningItems: [returnItem], completionHandler: nil)
        
        
        //  MARK: save Story
        //
        let persistenceController = PersistenceController.shared
        let context = persistenceController.container.viewContext
        
        let story = Story(context: context)
        story.text_ = textView.text
        story.timestamp_ = Date()
        
        context.saveContext()
    }
    
    /// To make an app be able to handle action extensions you want to call completionWithItemsHandler on your activity view controller. I included the code for my entire onShare function in my notes app below, which creates the activity view controller and then the code to accept the action extension.
    /// https://medium.com/@ales.musto/simple-text-action-extension-swift-3-c1ffaf3a197d
    func onShare(_ button:UIBarButtonItem) {
        var objectsToShare = [String]()
        
        if let text = textView.text {
            objectsToShare.append(text)
        }
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
        self.present(activityVC, animated: true, completion: nil)
        
        activityVC.completionWithItemsHandler =
            { (activityType, completed, returnedItems, error) in
                
                if returnedItems!.count > 0 {
                    
                    let textItem: NSExtensionItem =
                        returnedItems![0] as! NSExtensionItem
                    
                    let textItemProvider =
                        textItem.attachments![0] 
                    
                    if textItemProvider.hasItemConformingToTypeIdentifier(
                        kUTTypeText as String) {
                        
                        textItemProvider.loadItem(
                            forTypeIdentifier: kUTTypeText as String,
                            options: nil,
                            completionHandler: {(string, error) -> Void in
                                let newtext = string as! String
                                self.textView.text = newtext
                            })
                    }
                }
            }
    }
}
