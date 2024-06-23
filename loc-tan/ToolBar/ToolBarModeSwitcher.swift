//
//  ToolBarModeSwitcher.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/23.
//

import UIKit

/// ツールバーのモード切り替えボタン
class ToolBarModeSwitcher: UIButton {

    // MARK: - Properties
    
    /// 現在のモード
    private var currentMode: ToolBarMode = .normal
    
    override var buttonType: UIButton.ButtonType { .custom }
    
    // MARK: - Initializers
    
    init(mode: ToolBarMode) {
        self.currentMode = mode
        super.init(frame: .null)
        setup()
    }
    
    required init?(coder: NSCoder) {
        self.currentMode = coder.decodeObject(forKey: "mode") as? ToolBarMode ?? .normal
        super.init(coder: coder)
        setup()
    }
    
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(currentMode, forKey: "mode")
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(currentMode, forKey: "mode")
    }
    
    private func setup(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.imageView!.translatesAutoresizingMaskIntoConstraints = false
        self.imageView!.contentMode = .scaleAspectFit
        self.setImage(image(for: currentMode), for: .normal)
    }
    
    override func didMoveToSuperview() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalTo: heightAnchor),
            imageView!.widthAnchor.constraint(equalTo: widthAnchor),
            imageView!.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }
    
    // MARK: - Methods
    
    /// モードに対応する画像を取得
    /// - Parameter mode: モード
    /// - Returns: モードに対応する画像
    private func image(for mode: ToolBarMode) -> UIImage? {
        let symbolName: String
        switch mode {
        case .normal:
            symbolName = "square.2.layers.3d.bottom.filled"
        case .edit:
            symbolName = "square.2.layers.3d.top.filled"
        }
        return .init(systemName: symbolName)
    }
    
    /// モードを切り替える
    /// - Parameters:
    ///   - mode: モード
    ///   - duration: トランジション時間
    @MainActor
    func switchMode(to mode: ToolBarMode, duration: TimeInterval) async {
        self.isUserInteractionEnabled = false
        await UIView.transision(with: self, duration: duration, options: .transitionCrossDissolve) {
            self.setImage(self.image(for: mode), for: .normal)
        }
        self.isUserInteractionEnabled = true
        self.currentMode = mode
    }

}
