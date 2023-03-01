//
//  QueryRouter.swift
//  AGT
//
//  Created by r.latypov on 23.02.2023.
//

import Swifter
import SwiftyJSON
import XCTest

protocol QueryRouterDelegate: AnyObject {

    var preferredStubsVersion: Int { get }
}

final class QueryRouter {
    // MARK: Private properties

    private var stubs: [QueryStub] = []

    // MARK: Public properties

    weak var delegate: QueryRouterDelegate?
    var ignoredLoggingRequests: [String] = []

    // MARK: Public

    func addStub(items: [URLQueryItem], response: HttpResponse, version: Int = 0, requestBodyJSON: JSON?) {
        let items = Set(items)
        if let index = stubs.firstIndex(where: { $0.items == items && $0.version == version && $0.bodyJSON == requestBodyJSON }) {
            stubs[index] = QueryStub(items: items, response: response, version: version, bodyJSON: requestBodyJSON)
        } else {
            stubs.append(QueryStub(items: items, response: response, version: version, bodyJSON: requestBodyJSON))
        }
    }

    func handleRequest(_ request: HttpRequest) -> HttpResponse {
        let items = request.queryParams.map { URLQueryItem(name: $0.0, value: $0.1) }
        var bestStub: QueryStub?
        var bestWeight: QueryStubWeight = .invalid
        let preferredStubsVersion = delegate?.preferredStubsVersion ?? 0

        var bodyJSON: JSON?
        let jsonBodyString = String(bytes: request.body, encoding: .utf8)

        if !ignoredLoggingRequests.contains(request.path) {
            print(request.path, request.queryParams)
        }

        for stub in stubs where stub.version <= preferredStubsVersion {
            let weight = stub.match(items: items, preferredVersion: preferredStubsVersion, bodyJSON: bodyJSON)
            if weight > bestWeight {
                bestWeight = weight
                bestStub = stub
            }
        }

        guard let response = bestStub?.response else {
            XCTFail("Request: \(request.path) # no suitable response found")
            return .notFound
        }

        if !ignoredLoggingRequests.contains(request.path) {
            print(request.path, response.reasonPhrase)
        }

        return response
    }
}
