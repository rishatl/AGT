//
//  MyTestClass.swift
//  AGT_UITests
//
//  Created by r.latypov on 27.02.2023.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import AGT

final class MyTestClass: BaseMockTest {

    func testHappyPath() {

        launchApp()
        dynamicStubs.setupStubsForGroup("Test")

        let idddButton = app.otherElements["iddd"].firstMatch
        MainPage().apply {
            $0.runActivity(named: "Нажимаем на 1 элемент") { _ in
                idddButton.wait().tap()
            }
        }
    }
}

final class MainPage: BasePage {

    // MARK: Public Properties

    let displayName = "Стартовый экран"
}
