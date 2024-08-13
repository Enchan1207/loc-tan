//
//  ToolBarItemView.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/27.
//

import UIKit

class ToolBarItemView: UIButton {

    override var buttonType: UIButton.ButtonType { .custom }
    
    var item: ToolBarItem! {
        didSet {
            self.setImage(item.symbolImage, for: .normal)
        }
    }
    
    // MARK: - Initializing
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.imageView!.translatesAutoresizingMaskIntoConstraints = false
        self.imageView!.contentMode = .scaleAspectFit
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: heightAnchor),
            imageView!.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            imageView!.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            imageView!.leftAnchor.constraint(equalTo: leftAnchor, constant: 5),
            imageView!.rightAnchor.constraint(equalTo: rightAnchor, constant: -5),
        ])
    }

}

fileprivate extension ToolBarItem {
    
    var tagValue: Int {
        switch self {
        case .AspectRatio:
            return 1
        case .Rotate:
            return 2
        case .Fullsize:
            return 3
        case .Add:
            return 4
        }
    }
    
    init?(tagValue: Int){
        switch tagValue {
        case 1:
            self = .AspectRatio
        case 2:
            self = .Rotate
        case 3:
            self = .Fullsize
        case 4:
            self = .Add
        default:
            return nil
        }
    }
    
    var symbolImage: UIImage {
        let symbolName: String
        switch self {
        case .AspectRatio:
            symbolName = "aspectratio"
        case .Rotate:
            symbolName = "rotate.right"
        case .Fullsize:
            symbolName = "arrow.up.left.and.arrow.down.right"
        case .Add:
            symbolName = "plus.circle"
        }
        return .init(systemName: symbolName)!.withTintColor(.white, renderingMode: .alwaysOriginal)
    }
    
}
