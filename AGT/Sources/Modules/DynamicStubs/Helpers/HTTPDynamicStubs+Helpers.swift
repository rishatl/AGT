//
//  HTTPDynamicStubs+Helpers.swift
//  AGT
//
//  Created by r.latypov on 23.02.2023.
//

import Swifter
import XCTest

// MARK: - HTTPDynamicStubs + Helpers

extension HTTPDynamicStubs {
    func getFiles(
        inDirectory directoryURL: URL,
        recursively: Bool = false
    ) throws -> Set<URL> {
        let manager = FileManager.default
        let keys: Set<URLResourceKey> = [.isDirectoryKey]
        let options: FileManager.DirectoryEnumerationOptions = recursively
            ? [.skipsHiddenFiles]
            : [.skipsHiddenFiles, .skipsSubdirectoryDescendants]

        guard let enumerator = manager.enumerator(
            at: directoryURL,
            includingPropertiesForKeys: Array(keys),
            options: options
        ) else { fatalError("error with \(directoryURL)") }
        var passedFiles: Set<URL> = []
        var duplicatesFiles: [URL] = []
        for case let fileURL as URL in enumerator {
            guard try fileURL.resourceValues(forKeys: keys).isDirectory == false else { continue }
            guard Constants.availableStubExtensions.contains(fileURL.pathExtension) else { continue }
            guard !passedFiles.contains(fileURL) else {
                duplicatesFiles.append(fileURL)
                continue
            }
            passedFiles.insert(fileURL)
        }

        if !duplicatesFiles.isEmpty {
            fatalError("\(duplicatesFiles.description) error..")
        }

        return passedFiles
    }

    func findBodies(fromFiles files: Set<URL>) throws -> [String: URL] {
        var bodies: [String: URL] = [:]
        for file in files where file.lastPathComponent.hasPrefix(Constants.bodyPrefix) {
            let bodyName = file.deletingPathExtension().lastPathComponent
            if bodyName.count <= Constants.bodyPrefix.count {
                fatalError("\(bodyName) error..")
            } else {
                bodies[bodyName] = file
            }
        }
        return bodies
    }
}

// MARK: - HttpResponse custom init

extension HttpResponse {
    init?(statusCode: Int) {
        switch statusCode {
        case 500:
            self = .internalServerError
        case 401:
            self = .unauthorized
        case 403:
            self = .forbidden
        case 404:
            self = .notFound
        default:
            return nil
        }
    }
}
