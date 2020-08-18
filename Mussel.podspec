Pod::Spec.new do |s|
  s.name         = "Mussel"
  s.version      = "0.1.0"
  s.summary      = "A framework for easily testing Push Notifications and Routing in XCUITests"
  s.homepage     = "https://github.com/UrbanCompass/Mussel"
  s.license      = "MIT"
  s.author       = "Compass"
  s.ios.deployment_target = "13.0"
  s.source       = { :git => "https://github.com/UrbanCompass/Mussel.git", :tag => "#{s.version}" }
  s.source_files  = "Mussel/Mussel/MusselNotificationTester.swift", "Mussel/Mussel/Mussel.h"
  s.resources     = "scripts/run_notification_server.sh", "Mussel/Mussel/BuiltProduct/*"
  s.swift_version = '5.0'
end