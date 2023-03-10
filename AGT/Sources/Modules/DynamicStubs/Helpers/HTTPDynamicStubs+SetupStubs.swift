//
//  HTTPDynamicStubs+SetupStubs.swift
//  AGT
//
//  Created by r.latypov on 24.02.2023.
//

import Foundation

extension HTTPDynamicStubs {
    // MARK: Private Properties

    private var resourcesBundle: Bundle {
        let hostingBundle = Bundle.uiTest

        guard
            let bundlePath = hostingBundle.path(
                forResource: "SMEExampleUITestsUtilsResources",
                ofType: "bundle"
            ),
            let resourcesBundle = Bundle(path: bundlePath)
        else {
            fatalError("Failed to access Resources Bundle")
        }

        return resourcesBundle
    }

    private var allResourcesBundles: [Bundle] {
        let bundleUrls = Bundle.uiTest.urls(
            forResourcesWithExtension: "bundle",
            subdirectory: nil
        ) ?? []
        let resourcesBundles = bundleUrls
            .filter { $0.isTestResourceBundle }
            .compactMap { Bundle(url: $0) }

        return resourcesBundles
    }

    private var lastVisiteDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZ"
        return formatter
    }

    // MARK: Public

    func setupCommonStubs() {
        let milliseconds = Int64(Date().timeIntervalSince1970 * 1_000)
        let lastVisiteDate = lastVisiteDateFormatter.string(from: Date())

        for resourcesBundle in allResourcesBundles {
            // If an empty string is used for the path, then the path is assumed to be ".".
            setupStubsForPath(
                "",
                variables: ["milliseconds": "\(milliseconds)", "lastVisitDate": lastVisiteDate],
                bundle: resourcesBundle
            )
        }
    }

    func setupCommonAndIssueStubs(
        _ identifier: String,
        variables: [String: String] = [:],
        bundle: Bundle = .uiTest, /* .main is wrong */
        recursively: Bool = false
    ) {
        setupCommonStubs()
        setupStubsForIssue(
            identifier: identifier,
            variables: variables,
            bundle: bundle,
            recursively: recursively
        )
    }
}

private extension URL {
    var isTestResourceBundle: Bool {
        lastPathComponent.contains("Test") &&
            lastPathComponent.contains("Resources.bundle")
    }
}
