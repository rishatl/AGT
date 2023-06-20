//
//  MyTestClass.swift
//  AGT_UITests
//
//  Created by r.latypov on 27.02.2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import AGT

final class MyTestClass: BaseSnapshotTest {

    func testHappyPath() {

        launchApp()
        dynamicStubs.setupStubsForGroup("Test")

        let idddButton = app.otherElements["some id"].firstMatch
        let str1View = app.staticTexts["Send request"].firstMatch
        MainPage().apply {
            $0.runActivity(named: "Нажимаем на 1 элемент") { _ in
                idddButton.wait().tap()
            }
            verifyView(identifier: "snapshot_CF126E02-3923-4765-B6FD-3AB2C9959EB0")
            $0.runActivity(named: "Нажимаем на 2 элемент") { _ in
                str1View.wait().tap()
            }
        }
    }
}

final class MainPage: BasePage {

    // MARK: Public Properties

    let displayName = "Стартовый экран"
}
