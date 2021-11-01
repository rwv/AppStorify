import Foundation
import SwiftUI

class LocalApp {
    let path: String
    var info: [String: Any]!
    var appstore_app: AppStoreApp!
    unowned let parent: LocalApps
    
    init(path: String, country: String = DEFAULT_COUNTRY_CODE, parent: LocalApps) {
        self.path = path
        self.parent = parent
        
        DispatchQueue.global(qos: .default).async {
            // run "mdls -plist - path"
            let task = Process()
            let pipe = Pipe()
            task.standardOutput = pipe
            task.arguments = ["-plist", "-", path]
            task.launchPath = "/usr/bin/mdls"
            task.launch()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            
            var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml
            
            if let plistXML = String(data: data, encoding: .utf8),
               let plistData:Data = plistXML.data(using: .utf8),
               let swiftDictionary = try? PropertyListSerialization.propertyList(from: plistData, format: &propertyListFormat) as? [String:Any] {
                DispatchQueue.main.async {
                    self.info = swiftDictionary
                    // search for App Store
                    if !(self.isAppleApp) && !(self.isAppStore) {
                        self.appstore_app = AppStoreApp(searchAppName: self.appName, country: country, parent: self)
                    }
                    else {
                        self.parent.ready_apps_count += 1
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    print("Failed to get info from \(path)")
                    self.parent.ready_apps_count += 1
                }
            }
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
