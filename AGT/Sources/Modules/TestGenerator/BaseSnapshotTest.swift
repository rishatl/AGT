//
//  BaseSnapshotTest.swift
//  AGT
//
//  Created by r.latypov on 07.05.2023.
//

import XCTest

open class BaseSnapshotTest: BaseMockTest {

    // MARK: Private Properties

    private var snapshotTolerance: CGFloat = 0.0
    private var snapshotPixelTolerance: CGFloat = 0.0

    private lazy var homeGrabberLine = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        .otherElements["Home Grabber"]
        .otherElements
        .element(boundBy: 0)

    // MARK: Lifecycle

    override open func setUp() {
        super.setUp()

        let size = UIScreen.main.nativeBounds.size
        let pixelCount = size.width * size.height // 1536 x 2048 = 3145728
        let empiricalNumber: CGFloat = 7_500
        snapshotTolerance = empiricalNumber / pixelCount // 7500 / 3145728 = 0.0024

        snapshotPixelTolerance = 0.0157 // Empirical number

        // now it's native
        continueAfterFailure = CommandLine.arguments.contains(LaunchArgument.continueAfterFailure)

        recordMode = CommandLine.arguments.contains(LaunchArgument.recordMode)

        // скриншоты в разрезе модели устройства, версии OS, разрешения экрана
        fileNameOptions = [.device, .OS, .screenScale]

        UIPasteboard.general.items = []
    }

    // MARK: Private

    public func verifyView(identifier: String = "") {
        verifyElement(app, identifier: identifier)
    }

    public func verifyViewWithoutKeyboard(identifier: String = "") {
        // Look for window with keyboard inside
        let keyboardWindow = app.windows.allElementsBoundByIndex.first { window -> Bool in
            !window.keyboards.allElementsBoundByIndex.isEmpty
        }
        if let keyboardWindow = keyboardWindow {
            var keyboarElements = keyboardWindow.otherElements.allElementsBoundByIndex
            keyboarElements.remove(at: 0) // remove fullscreen root view
            if #available(iOS 13.0, *) {
                keyboarElements.removeAll(where: { !$0.scrollViews.allElementsBoundByIndex.isEmpty })
            }
            verifyElement(app, identifier: identifier, hiding: keyboarElements)
        } else {
            XCTFail("Keyboard not found")
        }
    }

    public func verifyElement(
        _ element: XCUIElement,
        identifier: String = "",
        hiding elementsToHide: [XCUIElement] = []
    ) {
        XCTContext.runActivity(named: "Сравниваем скрины \(identifier)") { _ in
            let screenshot = element.screenshot()
            var elementsToHide = elementsToHide
            elementsToHide.append(contentsOf: elementsToAlwaysBeHidden())
            let image = screenshot.image.removingComponents(hide: elementsToHide)
            let imageView = UIImageView(image: image)

            logger.add(
                title: "Скрин для проверки",
                isSuccess: true,
                screenshot: screenshot
            )

            // Cut inaccuracy bottom line if height isn't the integer
            // It can affect some cases, but let see
            imageView.contentMode = .top
            let sourceFrame = imageView.frame
            imageView.frame.integral(withRoundRule: .down)
            print("sourceFrame:", sourceFrame, ", fixed:", imageView.frame)
            XCTAssertTrue(LaunchArgument.FBSnapshotVerifyView)
        }
    }

    private func elementsToAlwaysBeHidden() -> [XCUIElement] {
        guard #available(iOS 13.0, *) else {
            // leave snapshots on ios 12 in peace
            return []
        }

        guard UIDevice.current.userInterfaceIdiom == .phone else {
            // no home grabber on ipad
            return []
        }

        return [homeGrabberLine]
    }

    public func verifyViewWithDelaySync(_ delayTime: UInt32 = 1, identifier: String = "") {
        sleep(delayTime)
        verifyElement(app, identifier: identifier)
    }

    public func verifyViewWithDelayAsync(_ delay: TimeInterval = 1, identifier: String = "") {
        let expectation = XCTestExpectation(description: "delay")
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            expectation.fulfill()
        }

        XCTWaiter().wait(for: [expectation], timeout: TimeInterval(delay + 1))
        verifyElement(app, identifier: identifier)
    }
}
