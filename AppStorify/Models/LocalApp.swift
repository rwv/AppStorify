import Foundation
import SwiftUI

enum LocalAppError: Error {
    case failedMDItem
}

class LocalApp {
    let path: String
    let info: [String: Any]
    var appstore_app: AppStoreApp!
    unowned let parent: LocalApps
    
    init(path: String, country: String = DEFAULT_COUNTRY_CODE, parent: LocalApps) {
        self.path = path
        self.parent = parent
        
        do {
            // run "mdls -plist - path"
            let task = Process()
            let pipe = Pipe()
            task.standardOutput = pipe
            task.arguments = ["-plist", "-", path]
            task.launchPath = "/usr/bin/mdls"
            task.launch()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            
            var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml
            
            guard let plistXML = String(data: data, encoding: .utf8),
                  let plistData:Data = plistXML.data(using: .utf8),
                  let swiftDictionary = try? PropertyListSerialization.propertyList(from: plistData, format: &propertyListFormat) as? [String:Any]
            else {
                throw LocalAppError.failedMDItem
            }
            
            self.info = swiftDictionary
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
