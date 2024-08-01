//
//  ViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/15.
//

import UIKit

class ViewController: UIViewController {
    
    private let boardModel = StickerBoardModel(stickers: [])
    
    private var boardController: StickerBoardViewController!
    
    private let boardModelSaveKey = "StickerBoard"
    
    /// ステッカーボードを配置するコンテナ
    @IBOutlet private weak var containerView: UIView! {
        didSet {
            boardController = .init(boardModel: boardModel)
            
            // StickerBoardViewControllerを子ViewControllerとして追加
            addChild(boardController)
            containerView.addSubview(boardController.view)
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: boardController.view.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: boardController.view.bottomAnchor),
                containerView.leftAnchor.constraint(equalTo: boardController.view.leftAnchor),
                containerView.rightAnchor.constraint(equalTo: boardController.view.rightAnchor),
            ])
            boardController.didMove(toParent: self)
        }
    }
    
    private let imageIdentifiers = [
        "dive_stage",
        "rainbow_bridge_night",
        "rainbow_bridge_noon",
        "tokyo_skytree"
    ]
    
    // MARK: - View lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func onTapAdd(_ sender: Any) {
        // TODO: PHPicker表示して画像選択、モデル生成時に一気に渡してしまう
        let center = CGPoint(x: (-100...100).randomElement()!, y: (-100...100).randomElement()!)
        print("new sticker will spawn at \(center.shortDescription)")
    }
}

