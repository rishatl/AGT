//
//  HTTPDynamicStubs.swift
//  AGT
//
//  Created by r.latypov on 23.02.2023.
//

import Swifter
import SwiftyJSON
import XCTest

public enum HTTPMethod: String {
    case POST
    case GET
    case PUT
    case PATCH
    case DELETE
}

public class HTTPDynamicStubs {
    enum Constants {
        static let bodyPrefix = "body"
        static let jsonFileExtension = ".json"
        static let availableStubExtensions = ["json", "pdf", "png", "jpeg", "jpg", "html"]
    }

    // MARK: Private data structures

    private enum StubFilenameComponentRangeIndex: Int, CaseIterable {
        case fullFilename
        case method // HTTP method
        case statusCode // HTTP status code
        case bodyJson // Body json
        case stubVersion // Stub version
        case url // URL path + query
        case fileExtension
    }

    private struct FileData {
        let name: String
        let url: URL
    }

    // MARK: Public properties

    public private(set) var port: UInt16 = 9_080
    public var preferredStubsVersion: Int = 0
    public var responsesWithDelay = false
    public var ignoredLoggingRequests: [String] = []
    public var requestHandler: ((HttpRequest) -> Void)?

    // MARK: Private properties

    private var queryRouters: [String: QueryRouter] = [:]

    private let stubFilenameRegExp: NSRegularExpression = {
        do {
            /* Filename examples:
             Basic:
             GET_api@v1@users@config?keys=general.json
             POST_api@v1.1@company@5-7IFIT6TC@operations.json

             With stub version:
             GET@1_api@v1@company@5-7IFIT6TC@accounts.json

             With specific json body:
             POST@body1_api@v1.1@company@5-7IFIT6TC@operations@statistics

             With specific status code:
             GET500_api@v1@company@5-7IFIT6TC@currencyControl@download@972298e8-4a49-11e9-9d40-0ad8210a0001.jpeg
             */

            // swiftlint:disable line_length
            let regexp = try NSRegularExpression(
                pattern: "(GET|PATCH|POST|PUT|DELETE)(500|404|403|401)?(?:@(\(Constants.bodyPrefix)\\d+))?(?:@(\\d+))?_([\\w\\@\\@\\d-_\\.\\*]+(?:\\?[^@]+)?)\\.(\\w+)",
                options: []
            )
            // swiftlint:enable line_length
            return regexp
        } catch {
            fatalError(error.localizedDescription)
        }
    }()

    private var server = HttpServer()

    // MARK: Lifecycle

    func setUp() {
        for _ in 0 ... 10 {
            do {
                try server.start(port)
            } catch {
                port += 1
                continue
            }
            break
        }

        if server.state != .running {
            XCTFail("Server didn't start: \(server.state)")
        }

        server.notFoundHandler = { request -> HttpResponse in
            let path = "path: \(request.path)"
            let queryParams = "queryParams: \(request.queryParams)"
            let method = "method: \(request.method)"
            let params = "params: \(request.params)"

            XCTFail(path + " " + queryParams + " " + method + " " + params)
            return .notFound
        }
    }

    func tearDown() {
        server.notFoundHandler = nil
        requestHandler = nil
        server.stop()
    }

    // MARK: Public

    public func setupResponseHandlerFor(
        path: String,
        method: HTTPMethod,
        handler: @escaping (HttpRequest) -> Bool
    ) {
        let serverHandler: (HttpRequest) -> HttpResponse = {
            handler($0) ? .accepted : .notAcceptable
        }

        switch method {
        case .GET:
            server.GET[path] = serverHandler
        case .POST:
            server.POST[path] = serverHandler
        case .PUT:
            server.PUT[path] = serverHandler
        case .PATCH:
            server.PATCH[path] = serverHandler
        case .DELETE:
            server.DELETE[path] = serverHandler
        }
    }

    public func setupStubsForIssue(
        identifier: String,
        variables: [String: String] = [:],
        bundle: Bundle = .uiTest, /* .main is wrong */
        recursively: Bool = false
    ) {
        setupStubsForPath(
            "Stubs/issue\(identifier)",
            variables: variables,
            bundle: bundle,
            recursively: recursively
        )
    }

    public func setupStubsForGroup(
        _ identifier: String,
        variables: [String: String] = [:],
        bundle: Bundle = .uiTest
    ) {
        setupStubsForPath(
            "Stubs/group\(identifier)",
            variables: variables,
            bundle: bundle
        )
    }

    public func setupStubsForPath(
        _ path: String,
        variables: [String: String] = [:],
        bundle: Bundle = .uiTest,
        recursively: Bool = false
    ) {
        guard let resourceURL = bundle.resourceURL else { return }

        let dirURL = URL(
            fileURLWithPath: path,
            isDirectory: true,
            relativeTo: resourceURL
        )

        guard FileManager.default.fileExists(atPath: dirURL.path) else {
            XCTFail("Directory \(path) not found.")
            return
        }

        let stubURLs: Set<URL>
        let bodies: [String: URL]
        do {
            var files = try getFiles(inDirectory: dirURL, recursively: recursively)
            bodies = try findBodies(fromFiles: files)
            for body in bodies.values {
                files.remove(body)
            }
            stubURLs = files

            for stubURL in stubURLs {
                let filename = stubURL.lastPathComponent
                let range = NSRange(filename.startIndex ..< filename.endIndex, in: filename)
                let nsFilename = filename as NSString

                let match = try matcheStubFilename(filename, range: range)

                var bodyFile: FileData?
                let jsonBodyRange = match.range(at: StubFilenameComponentRangeIndex.bodyJson.rawValue)
                if jsonBodyRange.location != NSNotFound {
                    let bodyFilename = nsFilename.substring(with: jsonBodyRange)
                    if let jsonBodyFileURL = bodies[bodyFilename] {
                        bodyFile = FileData(name: bodyFilename, url: jsonBodyFileURL)
                    }
                }

                let fileExtensionRange = match.range(at: StubFilenameComponentRangeIndex.fileExtension.rawValue)
                let fileExtension = "." + nsFilename.substring(with: fileExtensionRange)
                let shortFilename = String(filename.dropLast(fileExtension.count))
                try setupStub(
                    file: FileData(name: shortFilename, url: stubURL),
                    bodyFile: bodyFile,
                    variables: variables,
                    bundle: bundle
                )
            }
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    public func setupStub(
        filename: String,
        bodyFilename: String? = nil,
        variables: [String: String] = [:],
        bundle: Bundle = .uiTest
    ) {
        do {
            if let fileURL = bundle.url(
                forResource: filename,
                withExtension: Constants.jsonFileExtension
            ) {
                let file = FileData(name: filename, url: fileURL)

                var bodyFile: FileData?
                if let bodyFilename = bodyFilename {
                    if let jsonBodyFileURL = bundle.url(
                        forResource: bodyFilename,
                        withExtension: Constants.jsonFileExtension
                    ) {
                        bodyFile = FileData(name: bodyFilename, url: jsonBodyFileURL)
                    }
                }
                try setupStub(file: file, bodyFile: bodyFile, variables: variables, bundle: bundle)
            }
        } catch {
            XCTFail("Setup stub failure: \(error.localizedDescription)")
        }
    }

    public func setupStub(
        url: String,
        filename: String,
        bodyFilename: String? = nil,
        method: HTTPMethod = .GET,
        bundle: Bundle = .uiTest
    ) {
        guard let components = URLComponents(string: url) else {
            fatalError("Invalid url: \(url)")
        }

        let response = makeJSONResponseFromFile(filename, bundle: bundle)
        var bodyJSON: JSON?
        if let bodyFilename = bodyFilename {
            guard let jsonBodyFileURL = bundle.url(forResource: bodyFilename, withExtension: Constants.jsonFileExtension) else {
                fatalError("Body with name \(bodyFilename) not found.")
            }

            do {
                let jsonData = try Data(contentsOf: jsonBodyFileURL)
                bodyJSON = try JSON(data: jsonData)
            } catch {
                fatalError("Failed to read file \(jsonBodyFileURL.path): \(error.localizedDescription)")
            }
        }

        let router = obtainRouter(forMethod: method, urlPath: components.path)
        router.addStub(
            items: components.queryItems ?? [],
            response: response,
            requestBodyJSON: bodyJSON
        )
    }

    // MARK: Private

    private func setupStub(
        file: FileData,
        bodyFile: FileData? = nil,
        variables: [String: String] = [:],
        bundle _: Bundle = .uiTest
    ) throws {
        let fullFilename = file.name + Constants.jsonFileExtension
        let range = NSRange(fullFilename.startIndex ..< fullFilename.endIndex, in: fullFilename)
        let match = try matcheStubFilename(fullFilename, range: range)
        let nsFilename = fullFilename as NSString

        // Получаем HTTP Глагол (HTTP Method) из названия стаба (GET|PATCH|POST|PUT|DELETE)
        let rawMethod = nsFilename.substring(with: match.range(at: StubFilenameComponentRangeIndex.method.rawValue))
        guard let method = HTTPMethod(rawValue: rawMethod) else {
            fatalError("Invalid HTTP method '\(rawMethod)' in file '\(fullFilename)'")
        }

        let response: HttpResponse
        let statusCodeRange = match.range(at: StubFilenameComponentRangeIndex.statusCode.rawValue)
        if
            statusCodeRange.location != NSNotFound,
            let statusCode = Int(nsFilename.substring(with: statusCodeRange)),
            let tmp = HttpResponse(statusCode: statusCode)
        {
            response = tmp
        } else {
            response = try makeHttpResponseFromFile(fileURL: file.url, variables: variables)
        }

        var bodyJSON: JSON?
        if let bodyFile = bodyFile {
            let jsonData = try Data(contentsOf: bodyFile.url)
            bodyJSON = try JSON(data: jsonData)
        }

        var stubVersion = 0
        let stubVersionRange = match.range(at: StubFilenameComponentRangeIndex.stubVersion.rawValue)
        if stubVersionRange.location != NSNotFound {
            stubVersion = Int(nsFilename.substring(with: stubVersionRange))!
        }

        let urlRange = match.range(at: StubFilenameComponentRangeIndex.url.rawValue)
        let urlString = nsFilename.substring(with: urlRange).replacingOccurrences(of: "@", with: "/")
        if let urlComponents = URLComponents(string: urlString) {
            print("Adding stub for \(method.rawValue): \(urlString)")
            
            let router = obtainRouter(forMethod: method, urlPath: urlComponents.path)
            router.addStub(
                items: urlComponents.queryItems ?? [],
                response: response,
                version: stubVersion,
                requestBodyJSON: bodyJSON
            )
        }
    }

    private func matcheStubFilename(_ fullFilename: String, range: NSRange) throws -> NSTextCheckingResult {
        guard
            let match = stubFilenameRegExp.matches(in: fullFilename, range: range).first,
            match.numberOfRanges == StubFilenameComponentRangeIndex.allCases.count
        else {
            fatalError(fullFilename)
        }
        return match
    }

    private func obtainRouter(forMethod method: HTTPMethod, urlPath: String) -> QueryRouter {
        let key = "\(method.rawValue):\(urlPath)"
        let obtainedRouter: QueryRouter

        if let router = queryRouters[key] {
            obtainedRouter = router
        } else {
            let router = QueryRouter()
            router.delegate = self
            queryRouters[key] = router

            let handler: (HttpRequest) -> HttpResponse = { [weak self] in
                if self?.responsesWithDelay ?? false {
                    sleep(2)
                }
                let response = router.handleRequest($0)
                self?.requestHandler?($0)
                return response
            }

            switch method {
            case .GET:
                server.GET[urlPath] = handler

            case .POST:
                server.POST[urlPath] = handler

            case .PUT:
                server.PUT[urlPath] = handler

            case .PATCH:
                server.PATCH[urlPath] = handler

            case .DELETE:
                server.DELETE[urlPath] = handler
            }

            obtainedRouter = router
        }

        obtainedRouter.ignoredLoggingRequests = ignoredLoggingRequests
        return obtainedRouter
    }
}

// MARK: - QueryRouterDelegate

extension HTTPDynamicStubs: QueryRouterDelegate {}
