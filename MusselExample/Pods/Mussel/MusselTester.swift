// Copyright © 2021 Compass. All rights reserved.

import Foundation

protocol MusselTester: AnyObject {
    var targetAppBundleId: String { get set }
    var serverHost: String { get set }
    var serverPort: in_port_t { get set }
    var serverEndpoint: String { get set }

    init(targetAppBundleId: String)
}

extension MusselTester {
    func serverRequest(endpoint: String, json: [String: Any?]) {
        guard let endpointUrl = URL(string: endpoint) else {
            print("Invalid endpoint URL: \(endpoint)")
            return
        }

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
