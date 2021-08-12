# Mussel 🦪 💪 

A framework for easily testing Push Notifications, Universal Links and Routing in XCUITests.

<img alt="Mussel Logo" src="mussel-icon.png" width="200" height="200" style="display: block; margin-left: auto; margin-right: auto;"/>

As of Xcode 11.4, users are able to test Push Notifications via the simulator. Unfortunately, Apple has yet to introduce the ability to leverage this new method within the XCUITest Framework.

Testing Universal Links can also be an adventure, potentially accumulating lots of extra unwanted time in UI Tests, especially if your team wants to speed up your app's regression progress. Convential methods resorted to using iMessage or Contacts to open Universal Links which routed to a specific feature within an application.

Mussel introduces a quick and simple way to test Push Notifications and Universal Links which route to any specific features within your iOS app.

Let's Build some Mussel! 💪

# How it works

<img alt="Mussel Logo" src="mussel-server-diagram.png" width="500" height="400" style="display: block; margin-left: auto; margin-right: auto;"/>
<br/>

1. An Engineer triggers XCUITests in XCode manually or through your Continuous Integration platform of choice.
2. Mussel Server boots up along with the iOS Simulator.
3. A Test Case triggers a Push Notification or Universal Link Test Case.
4. The Test Case sends a payload containing Push Notification or Universal Link data via POST Request.
5. Server runs respective `xcrun simctl` command for Push Notifications or Universal Links.
6. The command presents a Push Notification or launches a Universal Link within the iOS Simulator.

# Installation

Mussel supports both Swift Package Manager and Cocoapods

## Installing with Cocoapods

Add the Mussel pod to the project's **UI Test Target** in your `podfile`:

```ruby
target 'ProjectUITests' do
    # Other UI Test pods....
    pod 'Mussel'
end
```

## Installing with Swift Package Manager

Add Mussel dependency to your `Package.swift`

```swift
let package = Package(
    name: "MyPackage",
    ...
    dependencies: [
        .package(url: "https://github.com/UrbanCompass/Mussel.git", .upToNextMajor(from: "x.x.x")),
    ],
    targets: [
        .target(name: "MyTarget", dependencies: [.product(name: "Mussel", package: "Mussel")])
    ]
)
```

## Usage

First, import the Mussel framework whenever you need to use it:

```swift
import Mussel
```

### Push Notifications

Initialize your `Mussel Tester` of choice, we'll start with the `MusselNotificationTester`. Use your Target App's Bundle Id to ensure notifications are sent to the correct simulator.

``` swift
let notificationTester = MusselNotificationTester(targetAppBundleId: "com.yourapp.bundleId")
```

Send a push notification with a simple message to your iOS Simulator:
```swift
notificationTester.triggerSimulatorNotification(withMessage: "Test Push Notification")
```

You can also send full APNS payloads for notifications with more complexity, supplying keys that are outside the `aps` payload. You can specify this payload as a Dictionary:

```swift
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

Then call `triggerSimulatorNotification` with your respective dictionary-converted APNS payload.

```swift
notificationTester.triggerSimulatorNotification(withFullPayload: testPayload)
```

### Universal Links ####

Initialize your `MusselUniversalLinkTester` using your Target App's Bundle Id to ensure notifications are sent to the correct simulator.

``` swift
let universalLinkTester = MusselUniversalLinkTester(targetAppBundleId: "com.example.yourAppBundleId")
```

Trigger your iOS Simulator to open a Universal Link:
```swift
universalLinkTester.open("exampleapp://example/content?id=2")
```


# Xcode build phases

In order for Mussel to work, the `MusselServer` must be running when tests are run. In CI it's recommended to download the `MusselServer` binary from [the releases tab](https://github.com/UrbanCompass/Mussel/releases) and ensure that is run before running your tests. 

If you are using Bitrise you can also checkout the [Mussel Bitrise Step](https://github.com/UrbanCompass/bitrise-step-mussel) which handles launching the server for you.

## Cocoapods

When using Cocoapods and for local development, you can ensure the `MusselServer` is run before your UI tests are by adding a Run Script phase to your UI test scheme:

```sh
${PODS_ROOT}/Mussel/run_server.sh
```

## Swift Package Manager

Since Swift Package Manager does not currently support run script phases for targets, you can get a similar experience by wrapping `MusselServer` as a build tool target and running it that way.

You can do this by:

1. Create a `BuildTools` directory in the same parent directory as your Xcode project
2. In the `BuildTools` directory create a `Package.swift`, which defines a target that can run `MusselServer`:
    ```swift
    import PackageDescription

    let package = Package(
        name: "BuildTools",
        platforms: [.macOS(.v10_13)],
        dependencies: [
            .package(url: "https://github.com/UrbanCompass/Mussel.git", from: "x.x.x"),
        ],
        targets: [.target(name: "BuildTools", path: "")]
    )
    ```
3. Add an empty `.swift` file in the `BuildTools` directory.
4. Add a new Run Script phase to your UI test scheme
    ```sh
    pushd BuildTools
    SDKROOT=macosx swift run -c release MusselServer > stdout 2>&1 &
    popd
    ```

**NOTE**: You may wish to check `BuildTools/Package.swift` into your source control so that the version used by your run-script phase is kept in version control. It is recommended to add the following to your .gitignore file: `BuildTools/.build` and `BuildTools/.swiftpm`.

# Examples

Check out the example project in [MusselExample](/MusselExample)

Here's a sample UI test that utilizes the Mussel framework for testing a __Push Notification__ use case:

```swift
import Mussel
import XCTest

class ExamplePushNotificationTest: XCTestCase {
    let app = XCUIApplication()
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    let notificationTester = MusselNotificationTester(targetAppBundleId: "com.yourapp.bundleId")

    func testSimulatorPush() {
        waitForElementToAppear(object: app.staticTexts["Mussel Push Notification Example"])
    
        // Launch springboard
        springboard.activate()

        // Trigger a push notification to the simulator
        notificationTester.triggerSimulatorNotification(withMessage: "Test Notification Message")

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

Here's a sample UI test that utilizes the Mussel framework for testing a __Universal Link__ use case:

```swift
import Mussel
import XCTest

class ExampleUniversalLinkTest: XCTestCase {
    let app = XCUIApplication()
    let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
    let universalLinkTester = MusselUniversalLinkTester(targetAppBundleId: "com.example.yourAppBundleId")

    func testSimulatorPush() {
        waitForElementToAppear(object: app.staticTexts["Mussel Universal Link Example"])
    
        // Launch springboard
        springboard.activate()

        // Trigger a Universal Link to the simulator
        universalLinkTester.open("mussleSampleApp://example/content?id=2")

        waitForElementToAppear(object: app.staticTexts["Mussel Universal Link Example"])
    }

    func waitForElementToAppear(object: Any) {
        let exists = NSPredicate(format: "exists == true")
        expectation(for: exists, evaluatedWith: object, handler: nil)
        waitForExpectations(timeout: 5, handler: nil)
    }
}
```

# Attribution

The original Mussel Icon can be found on clipartmax.com

Big thanks to [Matt Stanford](https://github.com/mattstanford/ "Matt Stanford") for finding an elegant and unprecedented way to test Push Notifications on the iOS Simulator with [Pterodactyl](https://github.com/mattstanford/Pterodactyl "Pterodactyl")

# Contributing

## Releasing

We are managing releases via [Bitrise](https://blog.bitrise.io/post/create-release-notes-and-versioning-with-the-release-workflow). This allows us to simplify the release process while getting rich release information in GitHub releases. 

To create a release:
- **Do not** create a release via GitHub, this is done by Bitrise.
- Ensure that all the required commits are ready and merged into `master`.
- Checkout to the `master` branch in your terminal and `git pull` to ensure you have the latest.
- When you have determined the release version and have made sure youre on the latest `master` branch run:
  ```sh
  git tag -a VERSION
  git push origin VERSION
  ```
