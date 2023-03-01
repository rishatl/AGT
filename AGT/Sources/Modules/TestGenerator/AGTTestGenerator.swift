//
//  AGTTestGenerator.swift
//  AGT
//
//  Created by r.latypov on 13.02.2023.
//

import Foundation

public class AGTTestGenerator {

    static func generateSwiftTest(fileName: String, identifiers: [String]) {
        let fileName = "\(fileName).swift"
        let folderPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].path

        let filePath = "\(folderPath)/\(fileName)"

        let generatedTest = createTest(testClassName: "\(fileName)", identifiers: identifiers)

        do {
            try generatedTest.write(toFile: filePath, atomically: true, encoding: .utf8)
        } catch {
            print("Error writing file: \(error.localizedDescription)")
        }

        print("File generated and saved at: \(filePath)")
    }

    private static func createTest(
        projectName: String? = nil,
        testClassName: String,
        identifiers: [String]
    ) -> String {
        var fileContent = """
import AGT

final class \(testClassName): BaseMockTest {

    func testHappyPath() {

        launchApp()
//        dynamicStubs.setupStubsForPath("Stubs/Loans/issue1104279")

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
