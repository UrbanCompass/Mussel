// Copyright © 2021 Compass. All rights reserved.

import Foundation

open class MusselTester {
    var targetAppBundleId: String
    private var simulatorId: String?
    private var simulatorDeviceSet: String?
    var serverHost: String = "localhost"
    var serverPort: in_port_t = 10004

    public init(targetAppBundleId: String) {
        self.targetAppBundleId = targetAppBundleId
        self.simulatorId = ProcessInfo.processInfo.environment["SIMULATOR_UDID"]
        self.simulatorDeviceSet = (ProcessInfo.processInfo.environment["HOME"]?.contains("XCTestDevices") ?? false) ? "testing" : nil
    }

    func serverRequestTask(_ task: String, options taskOptions: [String: Any?]) {
        let endpoint = "http://\(serverHost):\(serverPort)/\(task)"

        guard let endpointUrl = URL(string: endpoint) else {
            print("Invalid endpoint URL: \(endpoint)")
            return
        }

        let requestOptions = taskOptions.merging([
            "simulatorId": self.simulatorId,
            "simulatorDeviceSet": self.simulatorDeviceSet,
        ], uniquingKeysWith: { $1 })

        guard let data = try? JSONSerialization.data(withJSONObject: requestOptions, options: []) else {
            print("Invalid JSON: \(requestOptions)")
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
