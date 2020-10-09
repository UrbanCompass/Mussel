# Mussel 🦪💪 ![Cocoapods](https://cocoapod-badges.herokuapp.com/v/Mussel/badge.png)

A framework for easily testing Push Notifications, Universal Links and Routing in XCUITests.

<img alt="Mussel Logo" src="mussel-icon.png" width="200" height="200" style="display: block; margin-left: auto; margin-right: auto;"/>

As of Xcode 11.4, users are able to test push notifications via the simulator. Unfortunately, Apple has yet to introduce the ability to leverage this new method within the XCUITest Framework.

Testing Universal Links can also be an adventure, potentially accumulating lots of extra time in UI Tests. Convential methods resorted to using iMessage or Contacts to open Universal Links which routed to a specific feature within an application.

# How it works

<img alt="Mussel Logo" src="mussel-server-diagram.png" width="500" height="400" style="display: block; margin-left: auto; margin-right: auto;"/>
<br/>

1. Trigger XCUITests in XCode manually or through your Continuous Integration platform of choice.
2. Mussel Server boots up along with the iOS Simulator.
3. XCUITests trigger a Push Notification or Universal Link Test Case.
4. Test Case sends a payload containing Push Notification or Universal Link data via POST Request.
5. Server runs respective `xcrun simctl` command for Push Notifications or Universal Links.
6. The command presents a Push Notification or launches a Universal Link within the iOS Simulator.

# Installation

Mussel currently supports Cocoapods

### Cocoapods

Add the Mussel pod to the project's **UI Test Target** in your `podfile`:
```
target 'ProjectUITests' do
    # Other UI Test pods....
    pod 'Mussel'
end
```

After installing the `Mussel` pod, add the following run script to the `Build Phases` for your respective **UI Test Target**

```
"${PODS_ROOT}/Mussel/scripts/run_notification_server.sh"
```

## Usage

First, import the Mussel framework to your `XCTestCase` file:
```
import Mussel
```
<br/>

### Push Notifications ####

<br/>
Initialize your `Mussel Tester` of choice, we'll start with the `MusselNotificationTester`. Use your Target App's Bundle Id to ensure notifications are sent to the correct simulator.

``` swift
let notificationTester = MusselNotificationTester(targetAppBundleId: "com.yourapp.bundleId")
```

Send a push notification with a simple message to your iOS Simulator:
```swift
notificationTester.triggerSimulatorNotification(withMessage: "Test Push Notification")
```

You can also send full APNS payloads for notifications which are more complex, supplying keys that are outside the `aps` payload. You can specify this payload as a Dictionary:
``` swift
    let testPayload = [
        "aps": [
            "alert": [
                "title": "Test title",
                "subtitle": "Test subtitle",
                "body": "Test body"
            ],
            "badge": 24,
            "sound": "default"
        ],
        "listingId": "12345"
    ]
```

This dictionary is equivalent to the following APNS payload:
``` json
{
    "aps": { 
        "alert": {
            "title": "Test title",
            "subtitle": "Test subtitle",
            "body": "Test body"
        },
        "badge": 24,
        "sound": "sound",
    },
    "listingId": "12345"
}
```

Then call `triggerSimulatorNotification` with your respective dictionary-converted APNS payload.

``` swift
notificationTester.triggerSimulatorNotification(withFullPayload: testPayload)
```

<br/>

### Universal Links ####

<br/>

Initialize your `MusselUniversalLinkTester` using your Target App's Bundle Id to ensure notifications are sent to the correct simulator.

``` swift
let universalLinkTester = MusselUniversalLinkTester(targetAppBundleId: "com.example.yourAppBundleId")
```

Trigger your iOS Simulator to open a Universal Link:
```swift
universalLinkTester.open(withMessage: "exampleapp://example/content?id=2")
```

## Examples

Here's a sample UI test that utilizes the Mussel framework for testing a Push Notification use case:

```swift
import Mussel
import XCTest

class ExamplePushNotificationTest: XCTestCase {
    let app = XCUIApplication()
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    let notificationTester = MusselNotificationTester(targetAppBundleId: "com.yourapp.bundleId")

    func testSimulatorPush() {
        waitForElementToAppear(object: app.staticTexts["Mussel Push Notification Example"])

        // Trigger a push notification to the simulator
        notificationTester.triggerSimulatorNotification(withMessage: "Test Notification Message")
    
        // Launch springboard
        springboard.activate()

        // Tap the notification when it appears
        let springBoardNotification = springboard.otherElements["NotificationShortLookView"]
        waitForElementToAppear(object: springBoardNotification)
        springBoardNotification.tap()

        waitForElementToAppear(object: app.staticTexts["Mussel Push Notification Example"])
    }

    func waitForElementToAppear(object: Any) {
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: object, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
}
```

Here's a sample UI test that utilizes the Mussel framework for testing a Universal Link use case:
```swift
import Mussel
import XCTest

class ExampleUniversalLinkTest: XCTestCase {
    let app = XCUIApplication()
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    let universalLinkTester = MusselUniversalLinkTester(targetAppBundleId: "com.example.yourAppBundleId")

    func testSimulatorPush() {
        waitForElementToAppear(object: app.staticTexts["Mussel Universal Link Example"])

        // Trigger a Universal Link to the simulator
        universalLinkTester.open(withMessage: "mussleSampleApp://example/content?id=2")
    
        // Launch springboard
        springboard.activate()

        waitForElementToAppear(object: app.staticTexts["Mussel Universal Link Example"])
    }

    func waitForElementToAppear(object: Any) {
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: object, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
}
```

## Attribution

The original Mussel Icon can be found on clipartmax.com

Big thanks to [Matt Standford](https://github.com/mattstanford/ "Matt Standford") for finding an elegant and unprecedented way to test Push Notifications on the iOS Simulator with [Pterodactyl](https://github.com/mattstanford/Pterodactyl "Pterodactyl")
