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

class HighlightButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addTarget(self, action: #selector(switchHighlightedState), for: [.touchDown])
        self.backgroundColor = .grayvk
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.addTarget(self, action: #selector(switchHighlightedState), for: [.touchDown])
        self.backgroundColor = .grayvk
    }
    
    @objc
    func switchHighlightedState() {
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
    
    override var isHighlighted: Bool {
        willSet {
            if newValue {
                backgroundColor = .orangevk
            } else {
                backgroundColor = .grayvk
            }
        }
    }

}
