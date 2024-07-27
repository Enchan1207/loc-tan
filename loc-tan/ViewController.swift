//
//  ViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/15.
//

import UIKit

class ViewController: UIViewController {
    
    private var boardModel: StickerBoardModel!
    
    private var boardController: StickerBoardViewController!
    
    private let boardModelSaveKey = "StickerBoard"
    
    /// ステッカーボードを配置するコンテナ
    @IBOutlet private weak var containerView: UIView! {
        didSet {
            // 保存されているデータからボードモデルを再構成し、ビューコントローラを初期化
            boardModel = restoreBoardModel() ?? .init(stickers: [])
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
    
    private func restoreBoardModel() -> StickerBoardModel? {
        guard let storedData = UserDefaults.standard.data(forKey: boardModelSaveKey),
              let decodedBoard = try? JSONDecoder().decode(StickerBoardModel.self, from: storedData) else {return nil}
        
        return decodedBoard
    }
    
    
    @IBAction func onTapAdd(_ sender: Any) {
        let center = CGPoint(x: (-100...100).randomElement()!, y: (-100...100).randomElement()!)
        print("new sticker will spawn at \(center.shortDescription)")
        boardModel.add(.init(imageIdentifier: imageIdentifiers.randomElement()!, center: center, width: 300, angle: .zero))
    }
    
    
    @IBAction func onTapEncode(_ sender: Any) {
        guard let encodedData = try? JSONEncoder().encode(boardModel) else {return}
        UserDefaults.standard.setValue(encodedData, forKey: boardModelSaveKey)
    }
}

