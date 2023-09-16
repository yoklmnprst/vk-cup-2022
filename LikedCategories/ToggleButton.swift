/*
 MIT License

 Copyright (c) 2023 Andrey Yo

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */


import Foundation
import UIKit


extension UIButton {
    
    // This method based on image- and title- edge insets UIButton properties. So don't change this properties directly if you are using this method.
    func layoutMoveTitle(up pt: CGFloat) {
        if titleLabel != nil {
            titleEdgeInsets.top += pt/2
            titleEdgeInsets.bottom -= pt/2
        }
    }
    
    // This method based on image- and title- edge insets UIButton properties. So don't change this properties directly if you are using this method.
    func layoutMoveImage(up pt: CGFloat) {
        if titleLabel != nil {
            imageEdgeInsets.top += pt/2
            imageEdgeInsets.bottom -= pt/2
        }
    }
    
    // This method based on image- and title- edge insets UIButton properties. So don't change this properties directly if you are using this method.
    func layoutMoveImage(left: CGFloat) {
        imageEdgeInsets.left -= left/2
        imageEdgeInsets.right += left/2
    }
    
    // This method based on image- and title- edge insets UIButton properties. So don't change this properties directly if you are using this method.
    func layoutMoveTitle(left: CGFloat) {
        titleEdgeInsets.left -= left/2
        titleEdgeInsets.right += left/2
    }
    
    // This method based on image- and title- edge insets UIButton properties. So don't change this properties directly if you are using this method.
    func layoutToggleImageTitle() {
        
        if let imageSize = imageView?.intrinsicContentSize,
           let titleSize = titleLabel?.intrinsicContentSize
        {
            titleEdgeInsets.left *= -1
            titleEdgeInsets.right *= -1
            layoutMoveTitle(left: +2*imageSize.width)
            imageEdgeInsets.left *= -1
            imageEdgeInsets.right *= -1
            layoutMoveImage(left: -2*titleSize.width)
        }
    }
    
    // This method based on image- and title- edge insets UIButton properties. So don't change this properties directly if you are using this method.
    func layoutBetweenImageAndTitleAdd(space: CGFloat) {
        let isRTL = UIView.userInterfaceLayoutDirection(for: semanticContentAttribute) == .rightToLeft
        if isRTL {
            layoutMoveTitle(left: +space)
            layoutMoveImage(left: -space)
            contentEdgeInsets.left -= space/2
            contentEdgeInsets.right -= space/2
        } else {
            layoutMoveTitle(left: -space)
            layoutMoveImage(left: +space)
            contentEdgeInsets.left += space/2
            contentEdgeInsets.right += space/2
        }

    }
    
    // This method based on image- and title- edge insets UIButton properties. So don't change this properties directly if you are using this method.
    func layoutAddBorder(spaces: UIEdgeInsets) {
        contentEdgeInsets.right += spaces.right
        contentEdgeInsets.left += spaces.left
        contentEdgeInsets.top += spaces.top
        contentEdgeInsets.bottom += spaces.bottom
    }
}


// Button Styles:
extension UIColor {
    
    static var grayvk: UIColor {
        UIColor(red: 1, green: 1, blue: 1, alpha: 0.17)
    }
    
    static var orangevk: UIColor {
        UIColor(red: 1, green: 0.325, blue: 0.09, alpha: 1)
    }
}


extension UIImage {
    static func empty(width: CGFloat, height: CGFloat, color: UIColor = .clear, opaque: Bool = false) -> UIImage {
        let rect = CGRectMake(0, 0, width, height)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), opaque, 0.0)
        color.set()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image ?? UIImage()
    }
    
    static var plus: UIImage {
        UIImage(named: "divider-plus") ?? UIImage.empty(width: 41, height: 24)
    }
    
    static var done: UIImage {
        UIImage(named: "divider-done") ?? UIImage.empty(width: 41, height: 24)
    }
}


// press in - press out button
class ToggleButton: UIButton {
    
    // MARK: public api
    
    var title: String {
        get {
            title(for: .normal) ?? ""
        }
        set {
            let button = self
            button.setTitle(newValue, for: .normal)
            button.reconfigureLayoutStyle()
        }
    }

    var selectingChanged: ((_ newValue: Bool)->Void)?
    
    // MARK: implementation
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.adjustsImageWhenHighlighted = false
        self.addTarget(self, action: #selector(switchSelectedState), for: .touchUpInside)
        self.setImage(nil, for: .highlighted)
        self.isSelected = false // activating willSet handler for the first init
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.adjustsImageWhenHighlighted = false
        self.addTarget(self, action: #selector(switchSelectedState), for: .touchUpInside)
        self.setImage(nil, for: .highlighted)
        self.isSelected = false // activating willSet handler for the first init
    }
    
    func reconfigureLayoutStyle() {
        let button = self
        
        button.contentEdgeInsets = .zero
        button.imageEdgeInsets = .zero
        button.titleEdgeInsets = .zero
        
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        
        button.layer.cornerRadius = 12
        
        button.layoutAddBorder(spaces: UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 8))
        button.layoutBetweenImageAndTitleAdd(space: 6)
        button.layoutToggleImageTitle()
        button.layoutMoveTitle(up: 1)
    }
    
    @objc
    func switchSelectedState() {
        let button = self
        if let transitionView = button.snapshotView(afterScreenUpdates: false) {
            button.superview?.addSubview(transitionView)
            transitionView.frame = button.frame
            button.alpha = 0.0
            button.transform = CGAffineTransformMakeScale(0.9, 0.9)
            button.isSelected.toggle()
            UIView.animate(withDuration: 0.2, delay: 0.0, animations: {
                button.alpha = 1.0
                transitionView.alpha = 0.0
                transitionView.transform = CGAffineTransformMakeScale(0.9, 0.9)
                button.transform = .identity
            }, completion: { b in
                transitionView.removeFromSuperview()
            })
        }
    }
    
    override var isSelected: Bool {
        willSet {
            if newValue {
                backgroundColor = .orangevk
            } else {
                backgroundColor = .grayvk
            }
        }
        didSet {
            selectingChanged?(isSelected)
        }
    }
        
}

