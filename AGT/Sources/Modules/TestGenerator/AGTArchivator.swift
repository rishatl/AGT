//
//  AGTArchivator.swift
//  AGT
//
//  Created by r.latypov on 08.03.2023.
//

import Foundation
import SSZipArchive

final class AGTArchivator {

    static func uploadFolderAsZip(
        testName: String,
        folderPath: String,
        serverURL: String
    ) {
        let fileManager = FileManager.default
        let zipFileName = "\(testName).zip"
        let zipFilePath = "\(folderPath)/\(zipFileName)"
        
        if fileManager.fileExists(atPath: zipFilePath) {
            print("Archive file already exists.")
            return
        }
        
        let success = SSZipArchive.createZipFile(atPath: zipFilePath, withContentsOfDirectory: folderPath)
        guard success else {
            print("Failed to archive folder.")
            return
        }
        sendFile(zipFilePath: zipFilePath, url: serverURL)
    }

    private static func sendFile(
        zipFilePath: String,
        url: String
    ) {
        // Create a session configuration
        let sessionConfig = URLSessionConfiguration.default

        // Create a session with the configuration
        let session = URLSession(configuration: sessionConfig)

        // Create a URL pointing to the zip file
        let zipFileURL = URL(fileURLWithPath: zipFilePath)

        // Create a URLRequest with the destination URL
        guard let urlPath = URL(string: url) else {
            print("Invalid url path")
            return
        }
        var request = URLRequest(url: urlPath)
        request.httpMethod = "POST"

        // Create a data task with the zip file as the body
        let task = session.uploadTask(with: request, fromFile: zipFileURL) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            // Process the response if needed
            if let httpResponse = response as? HTTPURLResponse {
                print("Response status code: \(httpResponse.statusCode)")
                // Handle the response as needed
            }
        }

        // Start the data task
        task.resume()
    }
}
