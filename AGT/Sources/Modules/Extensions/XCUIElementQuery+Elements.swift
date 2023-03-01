//
//  XCUIElementQuery+Elements.swift
//  AGT
//
//  Created by r.latypov on 24.02.2023.
//

import XCTest

public extension XCUIElementQuery {
    func allElements(identifierContains: String) -> XCUIElementQuery {
        return matching(NSPredicate(format: "identifier CONTAINS[cd] '\(identifierContains)'"))
    }

    func allElements(identifier: String) -> XCUIElementQuery {
        return matching(NSPredicate(format: "identifier = %@", identifier))
    }

    func element(predicateString: String) -> XCUIElement {
        return element(matching: NSPredicate(format: predicateString))
    }

    func element(identifierContains: String) -> XCUIElement {
        return element(matching: NSPredicate(format: "identifier CONTAINS[cd] '\(identifierContains)'"))
    }

    func element(value: String) -> XCUIElement {
        return element(matching: NSPredicate(format: "value CONTAINS[cd] '\(value)'"))
    }

    func containing(label: String) -> XCUIElementQuery {
        return containing(NSPredicate(format: "label CONTAINS[cd] '\(label)'"))
    }

    func allElements(label: String) -> XCUIElementQuery {
        return matching(NSPredicate(format: "label = %@", label))
    }

    func allElements(placeholderValue: String) -> XCUIElementQuery {
        return matching(NSPredicate(format: "placeholderValue = %@", placeholderValue))
    }

    func allElements(labelBeginsWith: String) -> XCUIElementQuery {
        return matching(NSPredicate(format: "label BEGINSWITH %@", labelBeginsWith))
    }
}
