// Copyright © 2021 Compass. All rights reserved.

import Foundation

public class MusselUniversalLinkTester: MusselTester {
    public func open(_ link: String) {
        let options: [String: Any?] = [
            "link": link,
        ]

        serverRequestTask("simulatorUniversalLink", options: options)
    }
}
