// Copyright © 2021 Compass. All rights reserved.

import Foundation

public class MusselNotificationTester: MusselTester {
    var targetAppBundleId: String
    var serverHost: String = "localhost"
    var serverPort: in_port_t = 10004
    var serverEndpoint: String = "simulatorPush"

    public required init(targetAppBundleId: String) {
        self.targetAppBundleId = targetAppBundleId
    }

    public func triggerSimulatorNotification(withMessage message: String, additionalKeys: [String: Any]? = nil) {
        var innerAlert: [String: Any] = ["alert": message]
        if let additionalKeys = additionalKeys {
            innerAlert = innerAlert.merging(additionalKeys) { _, new in new }
        }
        let payload = ["aps": innerAlert]
        triggerSimulatorNotification(withFullPayload: payload)
    }

    public func triggerSimulatorNotification(withFullPayload payload: [String: Any]) {
        let endpoint = "http://\(serverHost):\(serverPort)/\(serverEndpoint)"

        let json: [String: Any?] = [
            "simulatorId": ProcessInfo.processInfo.environment["SIMULATOR_UDID"],
            "appBundleId": targetAppBundleId,
            "pushPayload": payload,
        ]

        serverRequest(endpoint: endpoint, json: json)
    }
}
