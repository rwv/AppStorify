import SwiftUI

struct AppRows: View {
    @ObservedObject var apps: LocalApps
    
    var body: some View {
        List(apps.matched_apps, id: \.self.path) {app in
            AppRow(app: app)
        }
    }
}

struct AppRows_Previews: PreviewProvider {
    static var previews: some View {
        AppRows(apps: LocalApps.shared)
    }
}
