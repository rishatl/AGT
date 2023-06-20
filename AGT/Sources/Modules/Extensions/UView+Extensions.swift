//
//  UIView+Extensions.swift
//  AGT
//
//  Created by r.latypov on 19.01.2023.
//

import UIKit
import FBSnapshotTestCase

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
        // Check if the view has already been processed
        if view?.isProcessed ?? false {
            return view
        }
        // Mark the view as processed
        view?.isProcessed = true
        
        let agt = AGT.sharedInstance()
        if view === self {
            if let str = view?.accessibilityIdentifier {
                agt.strings.append(nil)
                agt.snapshots.append(nil)
                agt.identifiers.append(str)
            } else if let view = view, let text = getTextFromView(view) {
                agt.identifiers.append(nil)
                agt.snapshots.append(nil)
                agt.strings.append(text)
            } else {
                guard let viewToSnapshot = view else {
                    fatalError("Unable to get reference to view")
                }
                agt.identifiers.append(nil)
                agt.strings.append(nil)
                // Take a snapshot of the view's current state
                UIGraphicsBeginImageContextWithOptions(viewToSnapshot.bounds.size, false, UIScreen.main.scale)
                viewToSnapshot.drawHierarchy(in: viewToSnapshot.bounds, afterScreenUpdates: true)
                guard let snapshotImage = UIGraphicsGetImageFromCurrentImageContext() else {
                    fatalError("Unable to get snapshot image")
                }
                UIGraphicsEndImageContext()

                // Convert the snapshot image to PNG data and save it to the device
                guard let data = snapshotImage.pngData() else {
                    fatalError("Unable to convert snapshot image to PNG data")
                }
                let fileManager = FileManager.default
                let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
                let subfolderURL = documentsDirectory.appendingPathComponent("\(AGT.testName!)/Snapshots")

                do {
                    try fileManager.createDirectory(at: subfolderURL, withIntermediateDirectories: true, attributes: nil)
                    let fileName = "snapshot_\(UUID().uuidString).png"
                    let fileURL = subfolderURL.appendingPathComponent(fileName)
                    try data.write(to: fileURL)
                    agt.snapshots.append(fileName)
                    print("File created successfully in \(AGT.testName!)/Snapshots folder")
                } catch {
                    print("Error creating file: \(error.localizedDescription)")
                }
            }
        }
        return view
    }

    private func getTextFromView(_ view: UIView) -> String? {
        if let label = view as? UILabel {
            return label.text
        }

        for subview in view.subviews {
            if let text = getTextFromView(subview) {
                return text
            }
        }

        return nil
    }
}

private extension UIView {
    struct AssociatedKeys {
        static var isProcessed = false
    }

    var isProcessed: Bool {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.isProcessed) as? Bool ?? false
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.isProcessed, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
