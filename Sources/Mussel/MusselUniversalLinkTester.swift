// Copyright © 2021 Compass. All rights reserved.

import Foundation

public class MusselUniversalLinkTester: MusselTester {
    var targetAppBundleId: String
    var serverHost: String = "localhost"
    var serverPort: in_port_t = 10004
    var serverEndpoint: String = "simulatorUniversalLink"

    public required init(targetAppBundleId: String) {
        self.targetAppBundleId = targetAppBundleId
    }

    public func open(_ link: String) {
        let endpoint = "http://\(serverHost):\(serverPort)/\(serverEndpoint)"

        let json: [String: Any?] = [
            "simulatorId": ProcessInfo.processInfo.environment["SIMULATOR_UDID"],
            "link": link,
        ]

        serverRequest(endpoint: endpoint, json: json)
    }
}
