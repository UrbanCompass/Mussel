//  Copyright © 2020 Compass. All rights reserved.

import Foundation

public class MusselNotificationTester {
    private let targetAppBundleId: String
    private let serverHost: String = "localhost"
    private let serverPort: in_port_t = 10003
    private let pushEndpoint = "simulatorPush"

    public init(targetAppBundleId: String) {
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
        let endpoint = "http://\(serverHost):\(serverPort)/\(pushEndpoint)"

        guard let endpointUrl = URL(string: endpoint) else {
            print("Invalid endpoint URL: \(endpoint)")
            return
        }

        var json = [String: Any]()
        json["simulatorId"] = ProcessInfo.processInfo.environment["SIMULATOR_UDID"]
        json["appBundleId"] = targetAppBundleId
        json["pushPayload"] = payload

        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            print("Invalid JSON: \(json)")
            return
        }

        var request = URLRequest(url: endpointUrl)
        request.httpMethod = "POST"
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
}
