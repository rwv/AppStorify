import SwiftUI

struct AppRows: View {
    @ObservedObject var apps: LocalApps
    
    init(apps: LocalApps) {
        self.apps = apps
    }
    
    var body: some View {
        List(apps.matched_apps) {app in
            AppRow(app: app)
        }
    }
}

struct AppRows_Previews: PreviewProvider {
    static var previews: some View {
        AppRows(apps: LocalApps())
    }
}
