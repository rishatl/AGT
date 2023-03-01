//
//  XCUIElement+Wait.swift
//  AGT
//
//  Created by r.latypov on 24.02.2023.
//

import XCTest

public enum ServiceConstants {
    public static let timeout: TimeInterval = 15
}

public extension XCUIElement {
    @discardableResult
    func wait(
        for timeout: TimeInterval = ServiceConstants.timeout,
        _ requiredState: ElementState = .exists,
        file: StaticString = #file,
        line: UInt = #line
    ) -> XCUIElement {
        let elementWithRequiredStateIsFound: Bool
        if case .exists = requiredState {
            elementWithRequiredStateIsFound = waitForExistence(timeout: timeout)
        } else {
            elementWithRequiredStateIsFound = waitFor(requiredState, timeout: timeout)
        }
        guard elementWithRequiredStateIsFound else {
            XCTFail(
                "Element (\(description)) with required state (\(requiredState.rawValue)) was not found",
                file: file,
                line: line
            )
            return self
        }

        return self
    }

    private func waitFor(_ requiredState: ElementState, timeout: TimeInterval) -> Bool {
        let predicate = NSPredicate(format: requiredState.rawValue)
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        return XCTWaiter.wait(for: [expectation], timeout: timeout) == .completed
    }

    func wait(value: Any, timeout: TimeInterval = 5) {
        let predicate = NSPredicate(format: "value = %@", argumentArray: [value])
        wait(predicate: predicate, timeout: timeout)
    }

    func wait(label: Any, timeout: TimeInterval = 5) {
        let predicate = NSPredicate(format: "label = %@", argumentArray: [label])
        wait(predicate: predicate, timeout: timeout)
    }

    private func wait(predicate: NSPredicate, timeout: TimeInterval) {
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)

        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
    }
}
