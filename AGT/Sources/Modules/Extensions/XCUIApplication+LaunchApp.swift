//
//  XCUIApplication+LaunchApp.swift
//  AGT
//
//  Created by r.latypov on 23.02.2023.
//

import XCTest

public enum LaunchArgument {
    static let `default` = [
        uiTests
    ]

    public static let continueAfterFailure = "--continueAfterFailure"
    public static let recordMode = "--recordMode"

    private static let uiTests = "--UI_TESTS"
}

enum EnvironmentVariable {
    static let deviceID = "deviceId"
    static let customCurrentDateKey = "CUSTOM_CURRENT_DATE"
}

// MARK: - Launch App On Contour

public extension XCUIApplication {
    func launch(withPort port: UInt16) {
        launchEnvironment["port"] = "\(port)"

        if launchEnvironment[EnvironmentVariable.deviceID] == nil {
            launchEnvironment[EnvironmentVariable.deviceID] = UUID().uuidString
        }

        launchArguments += LaunchArgument.default
        launch()
    }
}
