//
//  AGTTestGenerator.swift
//  AGT
//
//  Created by r.latypov on 13.02.2023.
//

import Foundation

public class AGTTestGenerator {

    static func createUITest(testName: String, identifiers: [String]) {
        let fileName = "\(testName).swift"
        let folderPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path

        let filePath = "\(folderPath)/\(testName)/\(fileName)"

        let generatedTest = generateTest(testClassName: "\(testName)", identifiers: identifiers)

        do {
            try generatedTest.write(toFile: filePath, atomically: true, encoding: .utf8)
        } catch {
            print("Error writing file: \(error.localizedDescription)")
        }

        print("Test generated and saved at: \(filePath)")
    }

    private static func generateTest(
        testClassName: String,
        identifiers: [String]
    ) -> String {
        var fileContent = """
import AGT

final class \(testClassName): BaseMockTest {

    func testHappyPath() {

        launchApp()
        dynamicStubs.setupStubsForGroup("\(testClassName)")

        // Assert

"""
        fileContent += generateStringWithIdentifiers(identifiers: identifiers)
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

    private static func generateStringWithIdentifiers(identifiers: [String]) -> String {
        var stringIdentifiers: String = ""
        for (index, identifier) in identifiers.enumerated() {
            stringIdentifiers += """
                            let view\(index) = app.otherElements["\(identifier)"].firstMatch

                    """
        }
        stringIdentifiers += """

                    MainPage().apply {

            """

        for (index, _) in identifiers.enumerated() {
            stringIdentifiers += """
                                $0.runActivity(named: "Нажимаем на \(index) элемент") { _ in
                                    view\(index).wait().tap()
                                }

                    """
        }
        stringIdentifiers += """
                }

        """
        return stringIdentifiers
    }
}
