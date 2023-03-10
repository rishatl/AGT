//
//  AGTArchivator.swift
//  AGT
//
//  Created by r.latypov on 08.03.2023.
//

//import Foundation
//import SSZipArchive
//
//final class AGTArchivator {
//
//    static func archiveAndSendFiles(filePaths: [String], repositoryURL: URL, personalAccessToken: String) {
//        // Create a temporary zip file path
//        let tempZipFilePath = NSTemporaryDirectory() + "archive.zip"
//
//        // Create a zip archive of the files
//        let zipArchiveSuccess = SSZipArchive.createZipFile(atPath: tempZipFilePath, withFilesAtPaths: filePaths)
//
//        // If the zip archive creation failed, return early
//        guard zipArchiveSuccess else {
//            print("Failed to create zip archive")
//            return
//        }
//
//        // Create a data representation of the zip archive
//        guard let zipArchiveData = FileManager.default.contents(atPath: tempZipFilePath) else {
//            print("Failed to get data representation of zip archive")
//            return
//        }
//
//        // Create the URL request to send the zip archive to the GitLab repository
//        var request = URLRequest(url: gitLabRepositoryURL)
//        request.httpMethod = "POST"
//        request.setValue("application/zip", forHTTPHeaderField: "Content-Type")
//        request.setValue("Bearer \(personalAccessToken)", forHTTPHeaderField: "Authorization")
//        request.httpBody = zipArchiveData
//
//        // Create the URLSession data task to send the request
//        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//            // Check for any errors
//            if let error = error {
//                print("Error sending zip archive: \(error)")
//                return
//            }
//
//            // Check the response status code
//            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
//                print("Error sending zip archive: Invalid response")
//                return
//            }
//
//            // The zip archive was successfully sent to the GitLab repository
//            print("Zip archive sent successfully")
//        }
//
//        // Start the URLSession data task
//        task.resume()
//    }
//}
