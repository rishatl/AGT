//
//  SnackBar.swift
//  AGT
//
//  Created by r.latypov on 07.01.2023.
//

import UIKit

public class SnackBar: UIView {

    private let textView = PaddingLabel()
    private var bottomPadding = CGFloat()
    private var textViewHeight: CGFloat = 30.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = CGRect.zero
        textView.frame = CGRect.zero
        self.addSubview(self.textView)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public func showSnackBar(view: UIView, bgColor: UIColor, text: String, textColor: UIColor, interval: Int){

        //Bottom Pading for iPhone X.
        if #available(iOS 11.0, *) {
            bottomPadding = view.safeAreaInsets.bottom
        }

        //Calcute height & set frame.
        layer.cornerRadius = 25
        frame = CGRect(x: 32, y: UIScreen.main.bounds.height + 30, width: UIScreen.main.bounds.width - 64, height: textViewHeight)
        textViewHeight = calculateHeight(text: text)
        textView.frame = CGRect(x: 32, y: 0, width: frame.width - 64, height: textViewHeight)

        textView.text = text
        textView.textColor = textColor
        textView.font = UIFont.systemFont(ofSize: 17, weight: .heavy)
        textView.textAlignment = NSTextAlignment.center
        textView.numberOfLines = 0
        backgroundColor = bgColor

        let shadowView = UIView()
        shadowView.dropShadow()
        view.addSubview(shadowView)
        shadowView.addSubview(self)

        UIView.animate(withDuration: 0.5) {
            self.frame = CGRect(x: 32, y: UIScreen.main.bounds.height - (self.textViewHeight + self.bottomPadding), width: UIScreen.main.bounds.width - 64, height: self.textViewHeight)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(interval)) {
            UIView.animate(withDuration: 0.5, animations: {
                self.frame = CGRect(x: 32, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width - 64, height: self.textViewHeight)
            }) { (success) in
                self.removeFromSuperview()
            }
        }
    }

    private func calculateHeight(text:String) -> CGFloat{
        let rect = text.boundingRect(with: CGSize(width: frame.width - 30 , height: 10000000), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)], context: nil)
        let height = rect.size.height <= 50 ? 50 : rect.size.height + 10
        return height
    }
}

private class PaddingLabel: UILabel {

    var topInset: CGFloat = 0.0
    var bottomInset: CGFloat = 0.0
    var leftInset: CGFloat = 15.0
    var rightInset: CGFloat = 15.0

    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset,
                      height: size.height + topInset + bottomInset)
    }
}

extension UIView {

    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 2
    }
}
