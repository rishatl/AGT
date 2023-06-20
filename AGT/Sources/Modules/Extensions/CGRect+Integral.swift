//
//  CGRect+Integral.swift
//  AGT
//
//  Created by r.latypov on 07.05.2023.
//

import CoreGraphics

public extension CGRect {
    mutating func integral(withRoundRule rule: FloatingPointRoundingRule) {
        origin.x = origin.x.rounded(rule)
        origin.y = origin.y.rounded(rule)
        size.width = width.rounded(rule)
        size.height = height.rounded(rule)
    }

    func integrated(withRoundRule rule: FloatingPointRoundingRule) -> CGRect {
        var newFrame = self
        newFrame.integral(withRoundRule: rule)
        return newFrame
    }
}
