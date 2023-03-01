//
//  BaseMockTest.swift
//  AGT
//
//  Created by r.latypov on 17.02.2023.
//

import MobileCoreServices
import XCTest

open class BaseMockTest: BaseTest {
    // MARK: Private Data Structures

    private enum Constants {
        static let resourcesBundleName = "AGTResources"
    }

    // MARK: Public Properties

    public lazy var dynamicStubs = HTTPDynamicStubs()

    public var setupCommonStubs = true

    // MARK: Private Properties

    private var resourcesBundle: Bundle {
        let hostingBundle = Bundle.uiTest

        guard
            let bundlePath = hostingBundle.path(forResource: Constants.resourcesBundleName, ofType: "bundle"),
            let resourcesBundle = Bundle(path: bundlePath)
        else {
            fatalError("Failed to access Resources Bundle")
        }

        return resourcesBundle
    }

    // MARK: Lifecycle

    override open func setUp() {
        super.setUp()
        dynamicStubs.setUp()
        dynamicStubs.ignoredLoggingRequests = ignoredLoggingRequests()

        dynamicStubs.setupExplicitlyFailResponse { errorMessage in
            DispatchQueue.main.async { [weak self] in
                self?.explicitlyFailResponseHandler(errorMessage)
            }
        }

        if setupCommonStubs {
            dynamicStubs.setupCommonStubs()
        }
    }

    // MARK: Public

    public func launchApp() {
        app.launch(withPort: dynamicStubs.port)
    }

    override open func tearDown() {
        super.tearDown()
        dynamicStubs.ignoredLoggingRequests = []
        dynamicStubs.tearDown()
    }

    open func ignoredLoggingRequests() -> [String] {
        return [
            "/app/business/events",
            "/app/business/messenger/conversations/convId",
            "/app/business/messenger/conversations/convId/messages"
        ]
    }

    private func explicitlyFailResponseHandler(_ errorMessage: String) {
        var uti = kUTTypePlainText as String

        var reason = errorMessage
        let json = kUTTypeJSON as String
        if errorMessage.starts(with: json) {
            uti = json
            reason.removeFirst(json.count)
        }

        let attachment = XCTAttachment(
            uniformTypeIdentifier: uti,
            name: "00 Log.error \(name) ",
            payload: reason.data(using: .utf8),
            userInfo: nil
        )
        add(attachment)

        XCTFail("Failed on Log.error: \(errorMessage)")
    }
}

final class QueryStubWeightTests: XCTestCase {
    func testFullMatches() {
        let weight1 = QueryStubWeight(fullMatches: 1, partialMatches: 2, stubVersion: 1)
        let weight2 = QueryStubWeight(fullMatches: 2, partialMatches: 1, stubVersion: 1)

        XCTAssertLessThan(weight1, weight2)
    }

    func testPartialMatches() {
        let weight1 = QueryStubWeight(fullMatches: 1, partialMatches: 1, stubVersion: 2)
        let weight2 = QueryStubWeight(fullMatches: 1, partialMatches: 2, stubVersion: 1)

        XCTAssertLessThan(weight1, weight2)
    }

    func testStubVersion() {
        let weight1 = QueryStubWeight(fullMatches: 1, partialMatches: 1, stubVersion: 1)
        let weight2 = QueryStubWeight(fullMatches: 1, partialMatches: 1, stubVersion: 2)

        XCTAssertLessThan(weight1, weight2)
    }

    func testInvalid() {
        let weight = QueryStubWeight(fullMatches: 0, partialMatches: 0, stubVersion: 0)
        XCTAssertLessThan(.invalid, weight)
    }
}
