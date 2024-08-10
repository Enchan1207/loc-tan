//
//  ToolBarModeSwitcher.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/27.
//

import UIKit

class ToolBarModeSwitcher: UIButton {

    override var buttonType: UIButton.ButtonType { .custom }
    
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
            imageView!.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView!.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView!.widthAnchor.constraint(equalTo: widthAnchor),
            imageView!.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
    // MARK: - Interface between ViewController
    
    func updateView(mode: ToolbarMode){
        self.setImage(mode.symbolImage, for: .normal)
    }
    
    @MainActor
    func updateView(mode: ToolbarMode, duration: TimeInterval) async {
        self.isUserInteractionEnabled = false
        await UIView.transision(with: self, duration: duration, options: .transitionCrossDissolve) {
            self.updateView(mode: mode)
        }
        self.isUserInteractionEnabled = true
    }

}

fileprivate extension ToolbarMode {
    
    var symbolImage: UIImage {
        let symbolName: String
        switch self {
        case .Camera:
            symbolName = "square.2.layers.3d.bottom.filled"
        case .Edit:
            symbolName = "square.2.layers.3d.top.filled"
        }
        return .init(systemName: symbolName)!.withTintColor(.white, renderingMode: .alwaysOriginal)
    }
    
}
