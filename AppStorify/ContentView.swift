import SwiftUI

struct ContentView: View {
    @ObservedObject var apps: LocalApps
    
    init(apps: LocalApps) {
        self.apps = apps
    }
    
    var body: some View {
        AppRows(apps: self.apps)
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(apps: LocalApps.shared)
    }
}
