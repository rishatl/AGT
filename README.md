# AGT
## Automation Generating Tests.

<p align="center">
<img alt="version" src="https://img.shields.io/badge/version-1.0.0-green.svg?style=flat-square" />
<a href="https://cocoapods.org/pods/AGT"><img alt="Cocoapods Compatible" src="https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat-square" /></a>
<a href="https://github.com/Carthage/Carthage"><img alt="Carthage Compatible" src="https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat-square" /></a>
<img alt="Platform" src="https://img.shields.io/badge/license-iOS-orange.svg?style=flat-square" />
<a href="https://opensource.org/licenses/MIT"><img alt="License" src="https://img.shields.io/badge/license-MIT-orange.svg?style=flat-square" /></a>
</p>


Regression testing is selective retesting of a system or component to verify that modifications have not caused unintended consequences and that the system or component is still compliant. Manual test writing in regression testing is becoming insufficient due to the increasing complexity of implementing software solutions for mobile applications. Using a test generation framework can significantly reduce the time and effort required for regression testing, while improving the quality of the process.

The concept developed involves a library, with the following functionality defined in the user experience:
- Shaking the mobile app activates the recording of the user program script => the recording of test item identification and collection of the necessary mock network request objects begins.
- The tester goes through the custom script of the new functionality written, on which the test needs to be written. At this time, the framework records and saves the identifiers of the clicked elements.
- Repeated shaking turns off the recording of the custom program script => the generation of the test program code begins. Archiving and sending files with the program code of the generated test and the corresponding stubs.

Supports Swift 5 and above - bridged also for Objective-C.

Feel free to contribute :)

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. To integrate AGT into your Xcode project using CocoaPods, specify it in your `Podfile`:

<pre>
use_frameworks!
pod 'AGT'
</pre>

To bundle only on some build configurations specify them after pod.

<pre>
use_frameworks!
pod 'AGT', :configurations => ['Debug', 'Test']
</pre>

### Manually

If you prefer not to use dependency managers, you can integrate AGT into your project manually.

You can do it by copying the "AGT" folder in your project (make sure that "Create groups" option is selected)

## Start

#### Swift
```swift
// AppDelegate
import AGT
AGT.sharedInstance().serverURL = "your url" // in application:
```

Here should be your url from the method on the server that will send to the repository with a .zip file of tests in the test environment of your project :) 

</pre>

## Usage 

Just shake your device and and record a custom script! 
Shake again and stop framework work!

## Custom gestures

By default the library registers for shake motion. If you want run framework with a different gesture, add the following line after the installation one
```swift
AGT.sharedInstance().setGesture(.custom)
```

## Important

- Functionality should only work on the QA loop!
- To check the element is obligatory! tap on elements

## Author

Латыпов Ришат Ильдарович, https://github.com/rishatl

## Licence

AGT is available under the MIT license. See the LICENSE file for more info.
