//
//  BaseTest.swift
//  AGT
//
//  Created by r.latypov on 17.02.2023.
//

import XCTest

open class BaseTest: XCTestCase {
    // MARK: Public Data Structures

    public typealias TestCustomCurrentDate = (testName: String, dateString: String)
    public typealias TestCustomDeviceID = (testName: String, deviceID: String)

    // MARK: Public Properties

    public lazy var app = XCUIApplication()

    // MARK: Lifecycle

    override open func setUp() {
        super.setUp()

        continueAfterFailure = false
    }

    // MARK: Public

    public func setupCurrentDate(_ testDates: [TestCustomCurrentDate]) {
        guard let test = testDates.first(where: { test in
            self.name == fullTestName(test.testName)
        }) else {
            return
        }

        app.launchEnvironment[EnvironmentVariable.customCurrentDateKey] = test.dateString
    }

    public func setupDeviceID(_ testDeviceIDs: [TestCustomDeviceID]) {
        guard let test = testDeviceIDs.first(where: { test in
            self.name == fullTestName(test.testName)
        }) else {
            return
        }

        app.launchEnvironment[EnvironmentVariable.deviceID] = test.deviceID
    }

    func fullTestName(_ testName: String) -> String {
        guard let infoDictionary = Bundle.uiTest.infoDictionary,
              let bundleName = infoDictionary["CFBundleName"] as? String
        else {
            fatalError()
        }
        let targetName = bundleName.replacingOccurrences(of: "-Runner", with: "")
        let classForCoder = String(describing: self.classForCoder)
        let testClassName = classForCoder.replacingOccurrences(of: "\(targetName).", with: "")
        return "-[\(testClassName) \(testName)]"
    }
}
