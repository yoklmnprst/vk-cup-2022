import UIKit


class ViewController: UIViewController {
    
    var dataSource: ButtonsCollectionViewDataSource!
    var delegate: ButtonsCollectionViewDelegate!
    
    lazy var grid: UICollectionView = {
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
        button.layoutAddBorder(spaces: UIEdgeInsets(top: 9, left: 13, bottom: 13, right: 11))
        button.layer.cornerRadius = 20
        button.backgroundColor = .grayvk
                
        button.setContentCompressionResistancePriority(.defaultHigh+1, for: .horizontal)
        button.setContentHuggingPriority(.defaultLow+1, for: .horizontal)
        let hstack = UIStackView(arrangedSubviews: [label, button])
        hstack.axis = .horizontal
        hstack.spacing = 12
        
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
        ])
        
        button.alpha = 0.0
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
        
        view.addSubview(header)
        view.addSubview(grid)
        view.addSubview(footer)
        
        // Layout:
        [header, grid, footer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        let mainBorder = view.layoutMarginsGuide
        NSLayoutConstraint.activate(
            [header, grid, footer].flatMap
            {[
                $0.rightAnchor.constraint(equalTo: mainBorder.rightAnchor),
                $0.leftAnchor .constraint(equalTo: mainBorder.leftAnchor),
            ]}
        )
        NSLayoutConstraint.activate([
                header.topAnchor.constraint(equalTo: mainBorder.topAnchor, constant: 16),
                header.bottomAnchor.constraint(equalTo: grid.topAnchor, constant: -24),
                grid.bottomAnchor.constraint(equalTo: footer.topAnchor),
                footer.bottomAnchor.constraint(equalTo: mainBorder.bottomAnchor),
                footer.heightAnchor.constraint(equalToConstant: 20+80+34),
            
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

