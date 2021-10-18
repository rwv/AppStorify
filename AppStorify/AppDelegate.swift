import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    let localAppsInstance = LocalApps()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(apps: self.localAppsInstance)

        
        // Create the titlebar accessory
        let titlebarAccessoryView = TitlebarAccessory(apps: self.localAppsInstance).edgesIgnoringSafeArea(.top)

        let accessoryHostingView = NSHostingView(rootView:titlebarAccessoryView)
        accessoryHostingView.frame.size = accessoryHostingView.fittingSize

        let titlebarAccessory = NSTitlebarAccessoryViewController()
        titlebarAccessory.view = accessoryHostingView

        
        // Create the window and set the content view.
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 500),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered, defer: false)
        window.center()
        window.title = "AppStorify"
        
        // Add the titlebar accessory
        window.addTitlebarAccessoryViewController(titlebarAccessory)
        
        window.contentView = NSHostingView(rootView: contentView)
        window.makeKeyAndOrderFront(nil)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
