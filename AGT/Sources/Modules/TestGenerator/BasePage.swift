//
//  BasePage.swift
//  AGT
//
//  Created by r.latypov on 16.02.2023.
//

import XCTest

public enum ElementState: String {
    case enabled = "enabled == true"
    case exists = "exists == true"
    case notExists = "exists == false"
    case hittable = "hittable == true"
}

public protocol BasePage {
    var displayName: String { get }
}

public extension BasePage {

    // MARK: Public Properties

    var app: XCUIApplication {
        return XCUIApplication()
    }

    // MARK: Public

    func apply(closure: (Self) -> Void) {
        closure(self)
    }

    @discardableResult
    func runActivity<T>(named name: String, activity: (Self) -> T) -> T {
        return XCTContext.runActivity(named: "\(displayName): \(name)") { _ in
            activity(self)
        }
    }

//    func verifyInPage(text: String) {
//        XCTContext.runActivity(named: "Проверяем текст \(text)") { _ in
//            let element = app.staticTexts.element(labelContains: text).firstMatch
//        }
//    }

    func verifyInPage(identifier: String) {
        XCTContext.runActivity(named: "Проверяем текст") { _ in
            _ = app.staticTexts.matching(identifier: identifier).firstMatch.label
        }
    }

    func waitForKeyboard(displayed: Bool) {
        let expectedKeyboardState = displayed ? "появление" : "скрытие"
        XCTContext.runActivity(named: "Ожидаем \(expectedKeyboardState) клавиатуры") { _ in
            let requiredState: ElementState = displayed ? .enabled : .notExists
            app.keyboards.firstMatch.wait(requiredState)
        }
    }

    func waitDelay(_ delay: TimeInterval) {
        runActivity(named: "Ждем \(delay) секунд") { _ in
            let expectation = XCTestExpectation(description: "delay")
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                expectation.fulfill()
            }
            XCTWaiter().wait(for: [expectation], timeout: TimeInterval(delay + 1))
        }
    }
}
