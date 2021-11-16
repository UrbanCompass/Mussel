// Copyright © 2021 Compass. All rights reserved.

import Foundation

public class MusselNotificationTester: MusselTester {
    public func triggerSimulatorNotification(withMessage message: String, additionalKeys: [String: Any]? = nil) {
        var innerAlert: [String: Any] = ["alert": message]
        if let additionalKeys = additionalKeys {
            innerAlert = innerAlert.merging(additionalKeys) { _, new in new }
        }
        let payload = ["aps": innerAlert]
        triggerSimulatorNotification(withFullPayload: payload)
    }

    public func triggerSimulatorNotification(withFullPayload payload: [String: Any]) {
        let options: [String: Any?] = [
            "appBundleId": targetAppBundleId,
            "pushPayload": payload,
        ]

        serverRequestTask("simulatorPush", options: options)
    }
}
