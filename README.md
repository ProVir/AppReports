# ProVir AppReports

[![CocoaPods Compatible](https://cocoapod-badges.herokuapp.com/v/AppReports/badge.png)](http://cocoapods.org/pods/AppReports)
[![Carthage Compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/ProVir/AppReports)
[![Platform](https://cocoapod-badges.herokuapp.com/p/AppReports/badge.png)](http://cocoapods.org/pods/AppReports)
[![License](https://cocoapod-badges.herokuapp.com/l/AppReports/badge.png)](https://github.com/ProVir/AppReports/blob/master/LICENSE)

Reports events and errors helper framework.
Write and use for swift.
You can write helper on swift with support objc as wrapper for this class.

This framework is safe thread.


- [Features](#features)
- [Requirements](#requirements)
- [Communication](#communication)
- [Installation](#installation)
- [Usage](#usage)
- [Author](#author)
- [License](#license)


## Features

- [x] General layout for reports event with custom type.
- [x] General layout for reports errors.


## Requirements

- iOS 8.0+
- Xcode 9.0
- Swift 4.0


## Communication

- If you **need help**, go to [provir.ru](http://provir.ru)
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.


## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

> CocoaPods 1.1.0+ is required to build AppReports 1.0.0+.

To integrate AppReports into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target '<Your Target Name>' do
  pod 'AppReports', '~> 1.0'
end
```

Then, run the following command:

```bash
$ pod install
```


### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate AppReports into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "ProVir/AppReports" ~> 1.0
```

Run `carthage update` to build the framework and drag the built `AppReports.framework` into your Xcode project.



### Manually

If you prefer not to use any of the aforementioned dependency managers, you can integrate ProVirAppReports into your project manually.

Copy files from directory `AppReports` in your project.


---


## Usage

To use the framework, you need:
1. Use alias or inherit from `AppReportsCore` (logs, but without errors and events),  `AppReportsGenericError` (logs and errors only) or `AppReportsGeneric` (full - logs, errors and events).
2. If you need to send errors, create your own type for errors or use the ready-made struct of `AppReportsErrorData`.
3. If you need to send events, create your own type for events. Usually this is enum or struct.
4. Perform `AppReportsCore.setup()` with parameters of the created you class or alias AppReports.

**Note:** To use the library, remember to include it in each file: `import AppReports`.


#### An example Helper for AppReports (Optional):
```swift
import Crashlytics
import AppReports

private class AppReportsHelper: AppReportsCoreHelper {

    func logAdded(_ newStr: String, currentLog: String) {
        //Crashlytics
        CLSLogv("%@", getVaList([newStr]))
    }

    func additionalValuesChanged(key: String, newValue: Any?, currentDict: [String : Any]) {
        Crashlytics.sharedInstance().setValue(newValue, forKey: key)
    }
}
```

#### An example AppReportErrorsDestionation with AppReportsErrorData as Type Error Data:
```swift
import Crashlytics
import AppReports


class AppReportsFabricErrors: AppReportErrorsDestionation<AppReportsErrorData> {
    override func reportError(appReport: AppReportsCore, data: AppReportsErrorData, logs: String, additionalValues: [String : Any]) {

        if let error = data.error {
            Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: data.userInfo)
        }
    }
}
```


#### An example AppReportEventsDestionation with Custom Type Event Data:
```swift
import Fabric
import AppReports

enum AppReportsEvent {

    enum SubEventOne {
        case one
        case two
    }

    enum SubEventTwo {
        case one
        case two
    }

    case oneType(SubEventOne)
    case twoType(SubEventTwo)
    case threeType(String)
    case fourType
}




class AppReportsFabricEvents: AppReportEventsDestionation<AppReportsEvent> {
    override func reportEvent(appReport: AppReportsCore, data: AppReportsEvent, additionalValues: [String : Any]) {
        let eventName:String

        switch data {
        case .oneType(let subEvent):
            switch subEvent {
            case .one:
                eventName = "One.one"

            case .two:
                .....
            }

            ...
        }

        Answers.logCustomEvent(withName: eventName, customAttributes: additionalValues)
    }
}
```



#### An example Setup AppReports:
```swift
import AppReports

typealias AppReports = AppReportsGeneric<AppReportsEvent, AppReportsErrorData>

extension AppReportsGeneric where TypeEventData == AppReportsEvent, TypeErrorData == AppReportsErrorData {

    static func createAppReports() {
        let helper = AppReportsHelper()

        setup(AppReports(settings: AppReportsCore.SettingsCore(),
                         helper: helper,
                         eventsDestionations: [AppReportsFabricEvents()],
                         errorsDestionations: [AppReportsFabricErrors]))
    }

    static var shared:AppReports {
        if let instance = coreShared as? AppReports {
            return instance
        } else {
            createAppReports()
            return coreShared as! AppReports
        }
    }
}
```

#### An example use AppReports:
```swift
import AppReports

func testLogs() {
    AppReports.log("Test log")
}

func testEvent() {
    AppReports.shared.reportEvent(.oneType(.one))
}

func testError(_ error:Error) {
    AppReports.shared.reportError(error)
}
```



## Author

[**ViR (Короткий Виталий)**](http://provir.ru)


## License

ProVir AppReports is released under the MIT license. [See LICENSE](https://github.com/ProVir/AppReports/blob/master/LICENSE) for details.



