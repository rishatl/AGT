//
//  HTTPDynamicStubs+Response.swift
//  AGT
//
//  Created by r.latypov on 24.02.2023.
//

import Swifter
import XCTest

extension HTTPDynamicStubs {
    // MARK: Public

    public func setupExplicitlyFailResponse(handler: @escaping (String) -> Void) {
        setupResponseHandlerFor(path: "explicitly-fail-current-ui-test", method: .POST) { info in
            let message = String(bytes: info.body, encoding: .utf8) ?? "message not received"
            handler(message)
            return true
        }
    }

    // MARK: Internal

    func makeHttpResponseFromFile(fileURL: URL, variables: [String: String]) throws -> HttpResponse {
        var data = try Data(contentsOf: fileURL)
        let ext = fileURL.pathExtension.lowercased()

        if ["pdf", "png", "jpg", "jpeg"].contains(ext) {
            return .ok(.data(data))
        }

        guard let stringData = String(data: data, encoding: .utf8) else {
            throw fatalError("\(fileURL) error..")
        }

        switch ext {
        case "json":
            if !variables.isEmpty {
                let jsonString = variables.reduce(stringData) { $0.replacingOccurrences(
                    of: "$(\($1.key))",
                    with: $1.value
                ) }
                data = jsonString.data(using: .utf8)!
            }
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject
            return .ok(.json(json))

        case "txt":
            return .ok(.text(stringData))

        case "html":
            return .ok(.html(stringData))

        default:
            XCTFail("Unsupported file type '\(ext)'")
            return .notFound
        }
    }

    func makeJSONResponseFromFile(_ fileName: String, bundle: Bundle) -> HttpResponse {
        guard let fileUrl = bundle.url(forResource: fileName, withExtension: "json") else {
            XCTFail("File not found: '\(fileName).json' in test bundle")
            return .notFound
        }

        do {
            let data = try Data(contentsOf: fileUrl, options: .uncached)
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject
            return HttpResponse.ok(.json(json))
        } catch {
            XCTFail(error.localizedDescription)
            return .internalServerError
        }
    }
}
