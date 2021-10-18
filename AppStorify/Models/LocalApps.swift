import Foundation

let PATH_TO_FIND = ["/Applications"]

class LocalApps: ObservableObject   {
    @Published var apps: [LocalApp] = []
    @Published var matched_apps: [LocalApp] = []
    @Published var ready_apps_count = 0
    
    init() {
        self.refresh()
    }
    
    func refresh() -> Void {
        self.apps = []
        self.matched_apps = []
        self.ready_apps_count = 0
        
        let paths = PATH_TO_FIND
        for path in paths {
            do {
                let app_filenames = try FileManager.default.contentsOfDirectory(atPath: path).filter { $0.suffix(4) == ".app" }
                for app_filename in app_filenames {
                    self.apps.append(LocalApp(path: path + "/" + app_filename, parent: self))
                }
            }
            catch {
                continue
            }
        }
    }
    
    var apps_count: Int {
        return apps.count
    }
    
    var fullLoaded: Bool {
        return apps_count == ready_apps_count
    }
}
