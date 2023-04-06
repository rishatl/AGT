//
//  AGT.swift
//  AGT
//
//  Created by r.latypov on 12.12.2022.
//

import UIKit

open class AGT: NSObject {

    fileprivate var navigationViewController: UINavigationController?

    fileprivate enum Constants: String {
        case alreadyStartedMessage = "Already started!"
        case alreadyStoppedMessage = "Already stopped!"
        case startedMessage = "Started!"
        case stoppedMessage = "Stopped!"
    }

    fileprivate var started: Bool = false
    fileprivate var presented: Bool = false
    fileprivate var enabled: Bool = false
    fileprivate var selectedGesture: AGTGesture = .shake
    fileprivate var ignoredURLs = [String]()
    fileprivate var ignoredURLsRegex = [NSRegularExpression]()
    fileprivate var lastVisitDate: Date = Date()

    internal var cacheStoragePolicy = URLCache.StoragePolicy.notAllowed

    internal static var testName: String?
    internal var folderURL: URL?
    internal var identifiers: [String?] = []
    internal var strings: [String] = []

    internal var repoURL: String?
    internal var authToken: String?

    class var swiftSharedInstance: AGT {
        struct Singleton {
            static let instance = AGT()
        }
        return Singleton.instance
    }

    @objc open class func sharedInstance() -> AGT {
        return AGT.swiftSharedInstance
    }

    @objc public enum AGTGesture: Int {
        case shake
        case custom
    }

    fileprivate func start() {
        guard !started else {
            showMessage(Constants.alreadyStartedMessage.rawValue)
            return
        }

        started = true
        URLSessionConfiguration.implementAGT()
        register()
        enable()
        fileStorageInit()
        do {
            try createTestFolder()
        } catch {
            fatalError("Create \(AGT.testName ?? "") folder error..")
        }
        showMessage(Constants.startedMessage.rawValue)
    }

    fileprivate func stop() {
        guard started else {
            showMessage(Constants.alreadyStoppedMessage.rawValue)
            return
        }

        AGTTestGenerator.createUITest(
            testName: AGT.testName!,
            identifiers: identifiers,
            strings: strings
        ) { folderPath in
            
            AGTArchivator.uploadFolderAsZip(
                testName: AGT.testName!,
                folderPath: folderPath
            )
            do {
                try self.deleteTestFolder(folderPath: folderPath)
            } catch {
                fatalError("Delete \(AGT.testName ?? "") folder error..")
            }
        }
        strings.removeAll()
        identifiers.removeAll()
        unregister()
        disable()
        clearOldData()
        started = false
        showMessage(Constants.stoppedMessage.rawValue)
    }

    fileprivate func showMessage(_ msg: String) {
        print("AGT \(msg)")
    }

    internal func isEnabled() -> Bool {
        return enabled
    }

    internal func enable() {
        enabled = true
    }

    internal func disable() {
        enabled = false
    }

    fileprivate func register() {
        URLProtocol.registerClass(AGTProtocol.self)
    }

    fileprivate func unregister() {
        URLProtocol.unregisterClass(AGTProtocol.self)
    }

    @objc func motionDetected() {
        toggleAGT()
    }

    fileprivate func showAGT() {
        if presented {
            return
        }

        showAGTFollowingPlatform()
        presented = true
    }

    fileprivate func hideAGT() {
        if !presented {
            return
        }

        hideAGTFollowingPlatform()
        presented = false
    }

    fileprivate func toggleAGT() {
        if presented {
            stop()
            hideAGT()
        } else {
            start()
            showAGT()
        }
        UIView.swizzele_UIView()
    }

    private func fileStorageInit() {
        clearOldData()
        AGTPath.deleteOldAGTLogs()
        AGTPath.createAGTDirIfNotExist()
    }

    private func createTestFolder() throws {
        let fileManager = FileManager.default
        let testName = "Test_issue_\(UUID().uuidString)"
        AGT.testName = testName

        // Get the documents directory URL
        guard let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "com.example.app", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve documents directory"])
        }

        // Append the folder name to the documents directory URL
        let folderURL = documentsURL.appendingPathComponent(testName, isDirectory: true)
        self.folderURL = folderURL

        // Create the folder if it doesn't already exist
        if !fileManager.fileExists(atPath: folderURL.path) {
            try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
        }
    }

    private func deleteTestFolder(folderPath: String) throws {
        let fileManager = FileManager.default
        try fileManager.removeItem(atPath: "\(folderPath)/\(AGT.testName!)")
    }

    internal func clearOldData() {
        AGTHTTPModelManager.shared.clear()

        AGTPath.deleteAGTDir()
        AGTPath.createAGTDirIfNotExist()
    }

    func getIgnoredURLs() -> [String] {
        return ignoredURLs
    }

    func getIgnoredURLsRegexes() -> [NSRegularExpression] {
        return ignoredURLsRegex
    }

    func getSelectedGesture() -> AGTGesture {
        return selectedGesture
    }
}

extension AGT {
    fileprivate var presentingViewController: UIViewController? {
        var rootViewController = UIWindow.keyWindow?.rootViewController
        while let controller = rootViewController?.presentedViewController {
            rootViewController = controller
        }
        return rootViewController
    }

    fileprivate func showAGTFollowingPlatform() {
        showSnackBar(on: presentingViewController, with: "Record Mode: On")
    }

    fileprivate func hideAGTFollowingPlatform() {
        navigationViewController?.presentingViewController?.dismiss(animated: true)
        navigationViewController = nil
        showSnackBar(on: presentingViewController, with: "Record Mode: Off")
    }

    fileprivate func showSnackBar(on rootViewController: UIViewController?, with text: String) {
        guard let rootView = rootViewController?.view else { return }
        let snackbarView = SnackBar()
        snackbarView.showSnackBar(view: rootView, bgColor: UIColor(red: 21 / 256, green: 21 / 256, blue: 21 / 256, alpha: 1), text: text, textColor: .white, interval: 2)
    }
}

extension AGT: UIAdaptivePresentationControllerDelegate {

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController)
    {
        guard self.started else { return }
        self.presented = false
    }
}
