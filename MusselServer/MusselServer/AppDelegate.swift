//  Copyright © 2020 Compass. All rights reserved.

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let serverManager = NotificationServerManager()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        serverManager.startServer()
    }
}
