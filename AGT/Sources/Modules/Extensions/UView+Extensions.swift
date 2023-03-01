//
//  UIView+Extensions.swift
//  AGT
//
//  Created by r.latypov on 19.01.2023.
//

import UIKit

fileprivate func swizzleMethod(_ `class`: AnyClass, _ original: Selector, _ swizzled: Selector) {

    if let original = class_getInstanceMethod(`class`, original),
       let swizzled = class_getInstanceMethod(`class`, swizzled)
    {
        method_exchangeImplementations(original, swizzled)
    } else {
        print("failed to swizzle: \(`class`.self), '\(original)', '\(swizzled)'")
    }
}

public extension UIView {

    static func swizzele_UIView() {
        swizzleMethod(UIView.self, #selector(UIView.hitTest(_:with:)), #selector(UIView.hitTest_x))
    }

    @objc private func hitTest_x(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        print(Self.self, #function)
        let view = self.hitTest_x(point, with: event)
        if view === self {
            guard let str = view?.accessibilityIdentifier else {
                print("accessibilityIdentifier entry error..")
                return nil
            }
            if !AGT.sharedInstance().identifiers.contains(str) {
                AGT.sharedInstance().identifiers.append(str)
            }
        }
        return view
    }
}
