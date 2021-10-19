import Foundation

let AVAILABLE_COUNTRY_CODE = ["CN", "US"]

class LocalApps: ObservableObject {
    static let shared = LocalApps()
    
    let paths_to_find: [String]
    
    @Published var country: String = Locale.current.regionCode ?? "US"
    @Published var apps: [LocalApp] = []
    @Published var matched_apps: [LocalApp] = []
    @Published var ready_apps_count = 0
    
    private init() {
        var _paths_to_find = ["/Applications"]
        if let userApplicationDirectoryPath = try? FileManager.default.url(for: .applicationDirectory,
                                                                           in: .userDomainMask,
                                                                           appropriateFor: nil,
                                                                           create: true).path {
            _paths_to_find.append(userApplicationDirectoryPath)
        }
        self.paths_to_find = _paths_to_find
        
        self.refresh()
    }
    
    func refresh() -> Void {
        self.apps = []
        self.matched_apps = []
        self.ready_apps_count = 0
        
        for path in paths_to_find {
            if let app_filenames = try? FileManager.default.contentsOfDirectory(atPath: path).filter({ $0.suffix(4) == ".app" }) {
                for app_filename in app_filenames {
                    self.apps.append(LocalApp(path: "\(path)/\(app_filename)", country: country, parent: self))
                }
            }
        }
    }
    
    func setCountryCode(country: String) -> Void {
        self.country = country
        self.refresh()
    }
    
    var apps_count: Int {
        return apps.count
    }
    
    var fullLoaded: Bool {
        return apps_count == ready_apps_count
    }
}
