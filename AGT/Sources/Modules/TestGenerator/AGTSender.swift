//
//  AGTSender.swift
//  AGT
//
//  Created by r.latypov on 06.04.2023.
//

import Foundation

final class AGTSender {

    static func sendFile(
        zipFilePath: String,
        token: String,
        repoName: String,
        repoFilePath: String,
        commitMessage: String
    ) {
        let token = "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"
        let repoName = "rishatl/AGT"
        let repoFilePath = "function"
        let commitMessage = "Added Test123"
        // Read file contents from disk
        guard let fileData = FileManager.default.contents(atPath: zipFilePath) else {
            print("Error: Could not read file at path: \(zipFilePath)")
            return
        }

        let fileContents = fileData.base64EncodedString()
        let apiURL = "https://api.github.com/repos/\(repoName)/contents/\(repoFilePath)"

        let body = [
            "message": commitMessage,
            "content": fileContents,
        ]

        let jsonData = try? JSONSerialization.data(withJSONObject: body)

        let url = URL(string: apiURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("token \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let _ = data,
                  let response = response as? HTTPURLResponse,
                  error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            if response.statusCode == 201 {
                print("File committed and pushed successfully!")
            } else {
                print("Error: \(response.statusCode)")
            }
        }

        task.resume()
    }

}
