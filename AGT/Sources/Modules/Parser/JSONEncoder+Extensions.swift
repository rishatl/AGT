//
//  JSONEncoder+Extensions.swift
//  AGT
//
//  Created by r.latypov on 19.01.2023.
//

import Foundation

extension JSONEncoder {
    static func encode<T: Encodable>(from data: T) {
        do {
            let jsonEncoder = JSONEncoder()
            jsonEncoder.outputFormatting = .prettyPrinted
            let json = try jsonEncoder.encode(data)
            let jsonString = String(data: json, encoding: .utf8)

            // iOS/Mac: Save to the App's documents directory
            saveToDocumentDirectory(jsonString)
            print(readFromDocumentDirectory())
        } catch {
            print(error.localizedDescription)
        }
    }

    static private func saveToDocumentDirectory(_ jsonString: String?) {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = path.appendingPathComponent("Output.json")

        do {
            try jsonString?.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print(error.localizedDescription)
        }
    }

    static private func readFromDocumentDirectory() -> String? {
        guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = path.appendingPathComponent("Output.json")

        var inString = ""
        do {
            inString = try String(contentsOf: fileURL)
        } catch {
            assertionFailure("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
        }

        return inString
    }
}
