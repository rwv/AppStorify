import Foundation
import SwiftUI

enum LocalAppError: Error {
    case failedMDItem
}

class LocalApp: Identifiable {
    let path: String
    let id = UUID()
    let info: [String: Any]
    var appstore_app: AppStoreApp!
    unowned let parent: LocalApps
    
    init(path: String, country: String = "US", parent: LocalApps) {
        self.path = path
        self.parent = parent
        
        do {
            let MDItem = MDItemCreate(kCFAllocatorDefault, path as CFString)
            let names = MDItemCopyAttributeNames(MDItem)
            let cfDict = MDItemCopyAttributes(MDItem, names);
            if let dict = cfDict as? [String: Any] {
                self.info = dict
            }
            else{
                throw LocalAppError.failedMDItem
            }
        } catch {
            print("Failed to get info from \(path)")
            self.info = [String: Any]()
            self.parent.ready_apps_count += 1
            return
        }
        
        // search for App Store
        if !(isAppleApp) && !(isAppStore) {
            self.appstore_app = AppStoreApp(searchAppName: self.appName, country: country, parent: self)
        }
        else {
            self.parent.ready_apps_count += 1
        }
    }
    
    var isAppStore: Bool {
        if let kMDItemAppStoreHasReceipt = self.info["kMDItemAppStoreHasReceipt"] as? Bool{
            return kMDItemAppStoreHasReceipt
        }
        else {
            return false
        }
    }
    
    var isAppleApp: Bool {
        if let kMDItemCFBundleIdentifier = self.info["kMDItemCFBundleIdentifier"] as? String{
            return kMDItemCFBundleIdentifier.contains("com.apple")
        }
        else{
            return false
        }
    }
    
    var appName: String {
        if let _kMDItemDisplayNameWithExtensions = self.info["_kMDItemDisplayNameWithExtensions"] as? String {
            return String(_kMDItemDisplayNameWithExtensions.prefix(_kMDItemDisplayNameWithExtensions.count - 4))
        }
        else {
            return (path as NSString).lastPathComponent
        }
    }
    
    var version: String? {
        return self.info["kMDItemVersion"] as? String
    }
    
    var icon: Image {
        return Image(nsImage: NSWorkspace.shared.icon(forFile: self.path))
    }
}
