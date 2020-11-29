//
//  ActionViewController.swift
//  ShareExtension
//
//  Created by Igor Malyarov on 30.11.2020.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
        if let item = self.extensionContext?.inputItems.first as? NSExtensionItem,
           let provider = item.attachments?.first,
           provider.hasItemConformingToTypeIdentifier(kUTTypeText as String) {
            // This is an image. We'll load it, then place it in our image view.
            weak var weakTextView = self.textView
            provider.loadItem(forTypeIdentifier: kUTTypeText as String, options: nil, completionHandler: { (result, error) in
                DispatchQueue.main.async {
                    if let strongTextView = weakTextView {
                        if let text = result as? String {
                            strongTextView.text = text
                        }
                    }
                }
            })
        }
    }
    
    @IBAction func done() {
        
        let returnProvider = NSItemProvider(item: textView.text as NSSecureCoding?,
                                            typeIdentifier: kUTTypeText as String)
        
        let returnItem = NSExtensionItem()
        
        returnItem.attachments = [returnProvider]
        self.extensionContext!.completeRequest(
            returningItems: [returnItem], completionHandler: nil)
        
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
//        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
    
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
