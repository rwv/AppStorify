import Foundation
import SwiftUI

let ITUNES_SEARCH_API = "https://itunes.apple.com/search"

class AppStoreApp: ObservableObject  {
    let searchAppName: String
    @Published var fetched = false
    @Published var matched = false
    @Published var appId: Int!
    @Published var version: String!
    weak var parent: LocalApp?
    
    init(searchAppName: String, country: String = "US", parent: LocalApp) {
        self.searchAppName = searchAppName
        self.parent = parent
        
        // generate search url
        let queryItems = [URLQueryItem(name: "term", value: self.searchAppName),
                          URLQueryItem(name: "country", value: country),
                          URLQueryItem(name: "media", value: "software"),
                          URLQueryItem(name: "entity", value: "macSoftware"),
                          URLQueryItem(name: "limit", value: "1"),]
        
        var urlComps = URLComponents(string: ITUNES_SEARCH_API)!
        urlComps.queryItems = queryItems
        let url = urlComps.url!

        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    defer {
                        DispatchQueue.main.async {
                            self.fetched = true
                            if let local_apps = self.parent?.parent {
                                local_apps.ready_apps_count += 1
                            }
                        }
                    }
                    if let response_info = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]{
                        if let results = response_info["results"] as? [[String:Any]] {
                            if results.count > 0 {
                                let result = results[0]
                                if let appStoreAppName = result["trackName"] as? String {
                                    // if app name equals
                                    if appStoreAppName == self.searchAppName {
                                        DispatchQueue.main.async {
                                            self.matched = true
                                            self.version = result["version"] as? String
                                            self.appId = result["trackId"] as? Int
                                            
                                            if let local_app = self.parent {
                                                local_app.parent.matched_apps.append(local_app)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                catch {
                    print(error)
                }
            }
        }.resume()
    }
    
    func openAppStore() ->  Void {
        if self.appId != nil {
            if let url = URL(string: "itms-apps://apple.com/app/id" + String(self.appId!)) {
                NSWorkspace.shared.open(url)
            }
        }
    }
}
