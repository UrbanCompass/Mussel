//  Copyright © 2020 Compass. All rights reserved.

import Foundation

public class MusselUniversalLinkTester: MusselTester {
    var targetAppBundleId: String
    var serverHost: String = "localhost"
    var serverPort: in_port_t = 10003
    var serverEndpoint: String = "simulatorUniversalLink"

    required public init(targetAppBundleId: String) {
        self.targetAppBundleId = targetAppBundleId
    }

    public func open(_ link: String) {
        let endpoint = "http://\(serverHost):\(serverPort)/\(serverEndpoint)"

        let json: [String: Any?] = [
            "simulatorId": ProcessInfo.processInfo.environment["SIMULATOR_UDID"],
            "link": link
        ]

        serverRequest(endpoint: endpoint, json: json)
    }
}
