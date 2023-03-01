//
//  QueryStubWeight.swift
//  AGT
//
//  Created by r.latypov on 23.02.2023.
//

struct QueryStubWeight: Comparable {

    private struct ComponentInfo {

        let mask: Int32
        let shift: Int32
    }

    private enum Components {

        static let fullMatches = ComponentInfo(mask: 0b0000_0000_1111_1111_0000_0000_0000_0000, shift: 16)
        static let partialMatches = ComponentInfo(mask: 0b0000_0000_0000_0000_1111_1111_0000_0000, shift: 8)
        static let stubVersion = ComponentInfo(mask: 0b0000_0000_0000_0000_0000_0000_1111_1111, shift: 0)
    }

    private let value: Int32

    static let invalid = QueryStubWeight(value: -1)

    init(fullMatches: Int32, partialMatches: Int32, stubVersion: Int32) {
        self.value = ((fullMatches << Components.fullMatches.shift) & Components.fullMatches.mask)
            | ((partialMatches << Components.partialMatches.shift) & Components.partialMatches.mask)
            | ((stubVersion << Components.stubVersion.shift) & Components.stubVersion.mask)
    }

    private init(value: Int32) {
        self.value = value
    }

    static func < (lhs: QueryStubWeight, rhs: QueryStubWeight) -> Bool {
        return lhs.value < rhs.value
    }
}
