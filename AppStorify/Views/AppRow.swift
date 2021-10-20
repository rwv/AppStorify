import SwiftUI

struct AppRow: View {
    let app: LocalApp
    //    @Binding var remoteVersion: String?
    @ObservedObject var store_app: AppStoreApp
    
    init(app: LocalApp) {
        self.app = app
        self.store_app = app.appstore_app
    }
    
    var body: some View {
        if store_app.matched {
            GeometryReader { gp in
                HStack{
                    Spacer(minLength: gp.size.width*0.05)
                    app.icon
                        .frame(width: gp.size.width*0.1, alignment: .leading)
                        .accessibility(label: Text("Icon of \(app.appName)"))
                    VStack(alignment: .leading) {
                        Text(app.appName)
                            .font(.title)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        Text(app.path)
                            .font(.caption)
                            .fontWeight(.light)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    }.frame(width: gp.size.width*0.4)
                    // version
                    VStack(alignment: .leading) {
                        if app.version != nil {
                            Text("Local version: \(app.version!)")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        }
                        else{
                            Text("Local version: N/A")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        }
                        if store_app.version != nil {
                            Text("Store version: \(store_app.version!)")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        }
                        else{
                            Text("Store version: N/A")
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                        }
                    }.frame(width: gp.size.width*0.2)
                    // go to App Store
                    Button(action: store_app.openAppStore)  {
                        Text("App Store")
                    }.frame(width: gp.size.width*0.2, alignment: .trailing)
                    .accessibility(label: Text("Go to App Store"))
                    Spacer(minLength: gp.size.width*0.05)
                }
            }.frame(height: 60).frame(maxWidth: .infinity)
        }
    }
}

struct AppRow_Previews: PreviewProvider {
    static var previews: some View {
        AppRow(app: LocalApp(path: "/Applications/iStat Menus.app", parent: LocalApps.shared))
    }
}
