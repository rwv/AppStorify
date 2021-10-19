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
    private weak var task: URLSessionTask?
    
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
        
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            
            do {
                defer {
                    DispatchQueue.main.async {
                        self.fetched = true
                        if let local_apps = self.parent?.parent {
                            local_apps.ready_apps_count += 1
                        }
                    }
                }
                
                guard let response_info = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] else { return }
                guard let results = response_info["results"] as? [[String:Any]] else { return }
                if results.count > 0 {
                    let result = results[0]
                    guard let appStoreAppName = result["trackName"] as? String else { return }
                    
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
            catch {
                print(error)
            }
        }
        
        task.resume()
        self.task = task
    }
    
    deinit {
        task?.cancel()
    }
    
    func openAppStore() -> Void {
        if let appId = self.appId {
            if let url = URL(string: "itms-apps://apple.com/app/id\(appId)") {
                NSWorkspace.shared.open(url)
            }
        }
    }
}
