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


import UIKit


extension UIStackView {
    
    // dummy class, not really used in view hierarchy,
    // only for internal purposes
    class Spacer: UIView {
        var space: CGFloat = .zero

        init(pt: CGFloat) {
            self.space = pt
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }
    }
    
    // Don't use .fillEqually with Spacers at the first or latest position.
    convenience init(_ axis: NSLayoutConstraint.Axis, distribution: UIStackView.Distribution, alignment: UIStackView.Alignment, spacing: CGFloat = .zero, _ arrangedSubviews: [UIView]) {
        var arrangedSubviews: [UIView] = arrangedSubviews
        var stackSubviews: [UIView] = []
        var stackSubviewsSpaces: [UIView : CGFloat] = [:]
        
        class EmptyView: UIView {
            override var intrinsicContentSize: CGSize {
                return .zero
            }
        }

        if arrangedSubviews.first is Spacer {
            let emptyView = EmptyView(frame: .zero)
            arrangedSubviews.insert(emptyView, at: 0)
        }

        if arrangedSubviews.last is Spacer {
            let emptyView = EmptyView(frame: .zero)
            arrangedSubviews.append(emptyView)
        }
        
        var lastNotSpacerSubview: UIView! // Is safe really due to previous algo block, arrangedSubviews always have not Spacer at first position.
        var iterator = arrangedSubviews.makeIterator()
        while let stackSubview = iterator.next() {
            if let spacer = stackSubview as? Spacer {
                stackSubviewsSpaces[lastNotSpacerSubview]! += spacer.space
            } else {
                lastNotSpacerSubview = stackSubview
                stackSubviews.append(lastNotSpacerSubview)
                stackSubviewsSpaces[lastNotSpacerSubview] = .zero
            }
        }
        
        self.init(arrangedSubviews: stackSubviews)
        self.axis = axis
        self.alignment = alignment
        self.distribution = distribution
        self.spacing = spacing
        
        for (stackSubview, stackSubviewSpace) in stackSubviewsSpaces {
            if stackSubviewSpace > .zero {
                self.setCustomSpacing(stackSubviewSpace, after: stackSubview)
            }
        }
    }
}


class ViewController: UIViewController {
    
    var dataSource: ButtonsCollectionViewDataSource!
    var delegate: ButtonsCollectionViewDelegate!
    
    lazy var content: UICollectionView = {
        let layout = ButtonsCollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
                
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

        self.dataSource = ButtonsCollectionViewDataSource()
        collectionView.dataSource = self.dataSource
        self.delegate = ButtonsCollectionViewDelegate()
        collectionView.delegate = self.delegate
        
        collectionView.registerReusableCell(ButtonCell.self)
        
        collectionView.backgroundColor = .clear
        
        return collectionView
    }()
    
    lazy var header: UIView = {
        var label = UILabel(frame: .zero)
        label.text = "Отметьте то, что вам интересно, чтобы настроить Дзен"
        label.numberOfLines = 10
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.48)

        var button = HighlightButton(frame: .zero)
        button.setTitle("Позже", for: .normal)
        button.titleLabel?.textColor = .white
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.alpha = 0.9
        button.layoutAddBorder(spaces: UIEdgeInsets(top: 9.5, left: 13.5, bottom: 10.5, right: 13.5))
        button.layer.cornerRadius = 20
        button.backgroundColor = .grayvk
                
        button.setContentCompressionResistancePriority(.defaultHigh+1, for: .horizontal)
        button.setContentHuggingPriority(.defaultLow+1, for: .horizontal)
        let hstack = UIStackView(.horizontal, distribution: .fill, alignment: .center, spacing: 12, [
            label,
            button
        ])
        
        return hstack
    }()
    
    lazy var footer: UIView = {
        let buttonSuperview = UIView(frame: .zero)
        let button = HighlightButton(frame: .zero)
        button.layer.cornerRadius = 40
        button.setTitle("Продолжить", for: .normal)
        buttonSuperview.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 211),
            button.heightAnchor.constraint(equalToConstant: 80),
            button.centerXAnchor.constraint(equalTo: buttonSuperview.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: buttonSuperview.centerYAnchor),
            button.topAnchor.constraint(equalTo: buttonSuperview.topAnchor),
            button.bottomAnchor.constraint(equalTo: buttonSuperview.bottomAnchor)
        ])
        
        button.alpha = .zero
        self.dataSource.selectingDidChanged = { [button] newValue in
            UIView.animate(withDuration: 0.25, delay: 0.0, animations: {
                button.alpha = newValue ? 1.0 : 0.0
            })
        }
                
        return buttonSuperview
    }()
    
    override func loadView() {
        // View hierarhy:
        self.view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        
        let hstack = UIStackView(.vertical, distribution: .fill, alignment: .fill, [
            UIStackView.Spacer(pt: 16),
            header,
            UIStackView.Spacer(pt: 24),
            content,
            UIStackView.Spacer(pt: 20),
            footer,
            UIStackView.Spacer(pt: 34)
        ])
        
        view.addSubview(hstack)
        
        let mainBorder = view.layoutMarginsGuide
        hstack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hstack.rightAnchor.constraint(equalTo: mainBorder.rightAnchor),
            hstack.leftAnchor.constraint(equalTo: mainBorder.leftAnchor),
            hstack.topAnchor.constraint(equalTo: mainBorder.topAnchor),
            hstack.bottomAnchor.constraint(equalTo: mainBorder.bottomAnchor),
        ])

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}

