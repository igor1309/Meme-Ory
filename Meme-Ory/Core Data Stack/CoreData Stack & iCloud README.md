#  CoreData Stack & iCloud README

Use **NSPersistentCloudKitContainer** to define CoreData Stack.

## Signing & Capabilities
for **App** & **Widget** targets:

* Add **App Groups** named "group.com.`<developer>`.`<name>`" with the same name for App and Widget targets.
* Use it in code defining CoreData Stack use `.containerURL(forSecurityApplicationGroupIdentifier: "group.com.<developer>.<name>")`.
* In **Background Modes** add *Remote Notifications*.
* In **iCloud** check *CloudKit* with the same container for App and Widget `iCloud.com.<developer>.<name>` ("iCloud" part is auto-added by Xcode).


***
### References

* [Designing a great model – Hacking with Swift+](https://www.hackingwithswift.com/plus/ultimate-portfolio-app/designing-a-great-model) (for App Settings & CoreDate Stack)
* [CloudKit Tutorial: Getting Started | raywenderlich.com](https://www.raywenderlich.com/4878052-cloudkit-tutorial-getting-started)
* [Enabling CloudKit in Your App](https://developer.apple.com/library/archive/documentation/DataManagement/Conceptual/CloudKitQuickStart/EnablingiCloudandConfiguringCloudKit/EnablingiCloudandConfiguringCloudKit.html)
* [Setting Up Core Data with CloudKit | Apple Developer Documentation](https://developer.apple.com/documentation/coredata/mirroring_a_core_data_store_with_cloudkit/setting_up_core_data_with_cloudkit)
* []()
