//
//  ReportLogger.swift
//  AGT
//
//  Created by r.latypov on 07.05.2023.
//

import XCTest

public enum ReportLogType {
    case success
    case warning
    case error

    var symbol: String {
        switch self {
        case .success:
            return "✅"

        case .warning:
            return "⚠️"

        case .error:
            return "❌"
        }
    }
}

public protocol IReportLogger {
    func add(title: String, type: ReportLogType)

    func add(title: String, isSuccess: Bool)
    func add(title: String, isSuccess: Bool, screenshot: XCUIScreenshot)
    func addEqual<T: Equatable>(title: String, first: T, second: T)
}

// Add log to report file
public final class ReportLogger: IReportLogger {

    // MARK: Lifecycle

    public init() {}

    // MARK: Public

    // Add note to report
    public func add(title: String, type: ReportLogType) {
        let screen = XCUIScreen.main
        screen.accessibilityValue = "jpg"
        let screenshot = screen.screenshot()

        add(title: title, type: type, screenshot: screenshot)
    }

    // Add note to report
    public func add(title: String, isSuccess: Bool) {
        let type = isSuccess ? ReportLogType.success : ReportLogType.error
        add(title: title, type: type)
    }

    // Add note to report with screenshot
    public func add(title: String, isSuccess: Bool, screenshot: XCUIScreenshot) {
        let type = isSuccess ? ReportLogType.success : ReportLogType.error
        add(title: title, type: type, screenshot: screenshot)
    }

    public func addEqual<T: Equatable>(title: String, first: T, second: T) {
        let fullTitle = title + " элементы: \(first) и \(second)"
        add(title: fullTitle, isSuccess: first == second)
    }

    // MARK: Private Methods

    private func add(title: String, type: ReportLogType, screenshot: XCUIScreenshot) {
        XCTContext.runActivity(named: title) { activity in
            let fullScreenshotAttachment = XCTAttachment(image: screenshot.image, quality: .medium)
            fullScreenshotAttachment.name = "Screenshot"
            fullScreenshotAttachment.lifetime = .deleteOnSuccess
            activity.add(fullScreenshotAttachment)
            if type == .error {
                XCTFail("Условие \(title) не выполнено")
            }
        }
    }
}
