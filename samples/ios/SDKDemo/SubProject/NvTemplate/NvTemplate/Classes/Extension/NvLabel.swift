//
//  NvLabel.swift
//  NvTemplate
//
//  Created by chengww on 2021/1/29.
//

import UIKit

class NvLabel: UILabel {
    var insets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5) {
        didSet {
            setNeedsDisplay()
        }
    }
    override func drawText(in rect: CGRect) {
        let insetRect = rect.inset(by: insets)
        super.drawText(in: insetRect)
    }

    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let width = originalContentSize.width + insets.left + insets.right
        let height = originalContentSize.height + insets.top + insets.bottom
        return CGSize(width: width, height: height)
    }

    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var adjustedSize = super.sizeThatFits(size)
        adjustedSize.width += insets.left + insets.right
        adjustedSize.height += insets.top + insets.bottom
        return adjustedSize
    }

}
extension UILabel {
    class func nv_label(text: String?, fontSize: Float, textColor: UIColor?) -> UILabel {
        let label = UILabel()
        label.textColor = textColor
        label.textAlignment = .center
        label.text = text
        label.font = UIFont.systemFont(ofSize: CGFloat(fontSize))
        return label
    }
}
