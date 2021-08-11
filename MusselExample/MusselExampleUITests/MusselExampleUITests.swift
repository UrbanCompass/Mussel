//
//  MusselExampleUITests.swift
//  MusselExampleUITests
//
//  Created by Renato Gamboa on 12/3/20.
//  Copyright © 2020 Compass. All rights reserved.
//

import Mussel
import XCTest

class MusselExampleUITests: XCTestCase {
    let app = XCUIApplication()
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    let notificationTester = MusselNotificationTester(targetAppBundleId: "com.compass.MusselExample")
    let universalLinkTester = MusselUniversalLinkTester(targetAppBundleId: "com.compass.MusselExample")

    func testUniversalLink() {
        app.launch()

        waitForElementToAppear(object: app.staticTexts["Mussel Push Notification Example"])

        // Launch springboard
        springboard.activate()

        // Trigger a Universal Link to the simulator
        universalLinkTester.open("com.MusselExample://")

        waitForElementToAppear(object: app.staticTexts["Mussel Universal Link Example"])

        sleep(2)
    }

    func testPushNotification() {
        app.launch()

        waitForElementToAppear(object: app.staticTexts["Mussel Push Notification Example"])

        // Launch springboard
        springboard.activate()

        // Trigger a push notification to the simulator
        notificationTester.triggerSimulatorNotification(withMessage: "Test Notification Message")

        // Tap the notification when it appears
        let springBoardNotification = springboard.otherElements["Notification"].descendants(matching: .any)["NotificationShortLookView"]
        waitForElementToAppear(object: springBoardNotification)
        springBoardNotification.tap()
    }

    func waitForElementToAppear(object: Any) {
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: object, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
}
