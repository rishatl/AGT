//
//  QueryStub.swift
//  AGT
//
//  Created by r.latypov on 23.02.2023.
//

import Swifter
import SwiftyJSON

struct QueryStub {

    let items: Set<URLQueryItem>
    let response: HttpResponse
    let version: Int
    let bodyJSON: JSON?

    func match(items: [URLQueryItem], preferredVersion: Int, bodyJSON: JSON?) -> QueryStubWeight {

        guard version <= preferredVersion else { return .invalid }

        var fullMatches: Int32 = 0
        var partialMatches: Int32 = 0

        if self.bodyJSON != nil {
            if self.bodyJSON == bodyJSON {
                fullMatches += 1
            } else {
                return .invalid
            }
        }

        for item in self.items {
            if item.value == "*" {
                guard items.contains(where: { $0.name == item.name }) else { return .invalid }
                partialMatches += 1
            } else if items.contains(where: { $0 == item }) {
                fullMatches += 1
            } else {
                return .invalid
            }
        }

        return QueryStubWeight(
            fullMatches: fullMatches,
            partialMatches: partialMatches,
            stubVersion: Int32(version)
        )
    }
}
