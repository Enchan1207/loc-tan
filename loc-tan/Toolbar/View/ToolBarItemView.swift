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
        self.transform = .init(rotationAngle: DeviceOrientation.shared.currentOrientation.rotationAngle)
        
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: heightAnchor),
            imageView!.topAnchor.constraint(equalTo: topAnchor, constant: 5),
            imageView!.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            imageView!.leftAnchor.constraint(equalTo: leftAnchor, constant: 5),
            imageView!.rightAnchor.constraint(equalTo: rightAnchor, constant: -5),
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChange), name: DeviceOrientation.orientationDidChangeNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func onDeviceOrientationChange(){
        UIView.animate(withDuration: 0.2) {[weak self] in
            self?.transform = .init(rotationAngle: DeviceOrientation.shared.currentOrientation.rotationAngle)
        }
    }

}

fileprivate extension ToolBarItem {
    
    var tagValue: Int {
        switch self {
        case .aspectRatio:
            return 1
        case .rotate:
            return 2
        case .expandToFullScreen:
            return 3
        case .add:
            return 4
        }
    }
    
    init?(tagValue: Int){
        switch tagValue {
        case 1:
            self = .aspectRatio
        case 2:
            self = .rotate
        case 3:
            self = .expandToFullScreen
        case 4:
            self = .add
        default:
            return nil
        }
    }
    
    var symbolImage: UIImage {
        let symbolName: String
        switch self {
        case .aspectRatio:
            symbolName = "aspectratio"
        case .rotate:
            symbolName = "rotate.right"
        case .expandToFullScreen:
            symbolName = "arrow.up.left.and.arrow.down.right"
        case .add:
            symbolName = "plus.circle"
        }
        return .init(systemName: symbolName)!.withTintColor(.white, renderingMode: .alwaysOriginal)
    }
    
}
