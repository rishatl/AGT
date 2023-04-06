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
        folderPath: String
    ) {
        let fileManager = FileManager.default
        let zipFileName = "\(testName).zip"
        let zipFilePath = "\(folderPath)/\(zipFileName)"
        
        if fileManager.fileExists(atPath: zipFilePath) {
            print("Archive file already exists.")
            return
        }
        
        let success = SSZipArchive.createZipFile(atPath: zipFilePath, withContentsOfDirectory: folderPath)
        if !success {
            print("Failed to archive folder.")
            return
        }
    }
}
