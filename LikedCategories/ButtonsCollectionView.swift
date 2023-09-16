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


extension UICollectionView {
    func registerReusableCell(_ cellClass: AnyClass) {
        register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
    }
    
    func unregisterReusableCell(_ cellClass: AnyClass) {
        register(nil as AnyClass?, forCellWithReuseIdentifier: String(describing: cellClass))
    }
    
    func dequeueReusableCell(_ cellClass: AnyClass, for indexPath: IndexPath) -> UICollectionViewCell {
        dequeueReusableCell(withReuseIdentifier: String(describing: cellClass), for: indexPath)
    }
}


class ButtonCell: UICollectionViewCell {
    var button: ToggleButton = {
        let button = ToggleButton(frame: .zero)
        button.setImage(.plus, for: .normal)
        button.setImage(.plus, for: .highlighted)
        
        button.setImage(.done, for: .selected)
        button.setImage(.done, for: [.selected, .highlighted])
                
        return button

    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(button)
        button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        button.frame = self.bounds
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override var intrinsicContentSize: CGSize {
        return button.intrinsicContentSize
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attr = layoutAttributes
        attr.size = self.intrinsicContentSize
        
        return attr
    }
}


class ButtonsCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let array = super.layoutAttributesForElements(in: rect)
        else {
            return nil
        }
        for i in 0..<array.count {
            if i == 0 {
                let current = array[0]
                current.frame.origin.x = 0
            } else {
                let current = array[i]
                let previous = array[i-1]
                let maximumInteritemSpacing = 8 as CGFloat
                let origin = CGRectGetMaxX(previous.frame)
                if (origin + maximumInteritemSpacing + current.frame.size.width < collectionViewContentSize.width) {
                    current.frame.origin.x = origin + maximumInteritemSpacing
                } else {
                    current.frame.origin.x = 0
                }
            }
        }
        
        return array
    }
    
}


class ButtonsCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    struct LikedCategory: ExpressibleByStringLiteral {
        
        typealias StringLiteralType = String
        
        var title: String
        var isSelected: Bool
        
        init(title: String, isSelected: Bool = false) {
            self.title = title
            self.isSelected = isSelected
        }
        
        init(stringLiteral value: String) {
            self.init(title: value)
        }
        
    }
    
    var selectingDidChanged: ((_ newValue: Bool)->Void)?
    
    var data: [LikedCategory] = [
        "Юмор",
        "Еда",
        "Кино",
        "Рестораны",
        "Прогулки",
        "Политика",
        "Новости",
        "Автомобили",
        "Сериалы",
        "Рецепты",
    ] {
        didSet {
            for item in data {
                if item.isSelected {
                    selectingDidChanged?(true)
                    return
                }
            }
            selectingDidChanged?(false)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ButtonCell.self, for: indexPath)
        guard let button: ToggleButton = (cell as? ButtonCell)?.button
        else {
            return cell
        }
        
        button.title = data[indexPath.row].title
        button.isSelected = data[indexPath.row].isSelected
        button.selectingChanged = { [index = indexPath.row, weak dataSource = self] newSelectingValue in
            dataSource?.data[index].isSelected = newSelectingValue
        }
        
        return cell
    }
}


class ButtonsCollectionViewDelegate: NSObject, UICollectionViewDelegateFlowLayout {
}




