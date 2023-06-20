//
//  UIImage+removingComponents.swift
//  AGT
//
//  Created by r.latypov on 07.05.2023.
//

import UIKit
import XCTest

extension UIImage {

    public func removingComponents(hide elements: [XCUIElement] = [], from parentElement: XCUIElement? = nil) -> UIImage? {
        var resultImage = self

        // закрашиваем ui элементы
        if let parentElement = parentElement, let newImage = hideUIElements(elements, from: parentElement) {
            resultImage = newImage
        } else if let newImage = hideUIElements(elements) {
            resultImage = newImage
        }

        return resultImage
    }

    private func hideUIElements(_ elements: [XCUIElement]) -> UIImage? {
        let imageSize = size
        let scale: CGFloat = 0

        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        draw(at: CGPoint(x: 0, y: 0))
        UIColor.black.setFill()
        for element in elements {
            UIRectFill(element.frame)
        }
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }

    private func hideUIElements(_ elements: [XCUIElement], from parentElement: XCUIElement) -> UIImage? {
        let imageSize = size
        let scale: CGFloat = 0

        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        draw(at: CGPoint(x: 0, y: 0))
        UIColor.black.setFill()
        for element in elements {
            let originX = element.frame.origin.x - parentElement.frame.origin.x
            let originY = element.frame.origin.y - parentElement.frame.origin.y
            let frame = CGRect(
                x: originX,
                y: originY,
                width: element.frame.width,
                height: element.frame.height
            )
            UIRectFill(frame)
        }
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage
    }
}
