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
