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

        let dispatchGroup = DispatchGroup()

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                debugPrint("Mussel received error: \(error.localizedDescription)")
            } else if let response = response as? HTTPURLResponse {
                debugPrint("Mussel received response status code \(response.statusCode)")
            } else {
                debugPrint("Mussel request finished, but with an unexpected result. Maybe MusselServer isn't running?")
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        task.resume()
        
        // Wait until the task completes
        dispatchGroup.wait()
    }
}
