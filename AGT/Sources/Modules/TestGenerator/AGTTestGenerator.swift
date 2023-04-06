//
//  AGTTestGenerator.swift
//  AGT
//
//  Created by r.latypov on 13.02.2023.
//

import Foundation

public class AGTTestGenerator {

    static func createUITest(testName: String, identifiers: [String?], strings: [String], completion: @escaping (String) -> Void) {
        let fileName = "\(testName).swift"
        let folderPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path

        let filePath = "\(folderPath)/\(testName)/\(fileName)"

        let generatedTest = generateTest(testClassName: "\(testName)", identifiers: identifiers, strings: strings)

        do {
            try generatedTest.write(toFile: filePath, atomically: true, encoding: .utf8)
        } catch {
            print("Error writing file: \(error.localizedDescription)")
        }

        print("Test generated and saved at: \(filePath)")
        completion(folderPath)
    }

    private static func generateTest(
        testClassName: String,
        identifiers: [String?],
        strings: [String]
    ) -> String {
        var fileContent = """
import AGT

final class \(testClassName): BaseMockTest {

    func testHappyPath() {

        launchApp()
        dynamicStubs.setupStubsForGroup("\(testClassName)")

        // Assert

"""
        fileContent += generateStringWithIdentifiers(identifiers: identifiers, strings: strings)
        fileContent += """
    }
}

final class MainPage: BasePage {

    // MARK: Public Properties

    let displayName = "Стартовый экран"
}
"""
        return fileContent
    }

    private static func generateStringWithIdentifiers(identifiers: [String?], strings: [String]) -> String {
        var stringIdentifiers: String = ""
        for (index, identifier) in identifiers.enumerated() {
            if let identifier = identifier {
                stringIdentifiers += """
                            let idView\(index) = app.otherElements["\(identifier)"].firstMatch

                    """
            } else {
                for string in strings {
                    stringIdentifiers += """
                                        let strView\(index) = app.staticTexts["\(string)"].firstMatch

                                """
                }
            }
        }
        stringIdentifiers += """

                    MainPage().apply {

            """

        for (index, identifier) in identifiers.enumerated() {
            if let _ = identifier {
                stringIdentifiers += """
                                $0.runActivity(named: "Нажимаем на \(index) элемент с идентификатором") { _ in
                                    idView\(index).wait().tap()
                                }

                    """
            } else {
                stringIdentifiers += """
                                $0.runActivity(named: "Нажимаем на \(index) элемент с текстом") { _ in
                                    strView\(index).wait().tap()
                                }

                    """
            }
        }
        stringIdentifiers += """
                }

        """
        return stringIdentifiers
    }
}
