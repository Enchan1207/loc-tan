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
    
    private var lastEncodedData: Data?
    
    @IBOutlet private weak var boardContainer: UIView!
    
    private let imageIdentifiers = [
        "dive_stage",
        "rainbow_bridge_night",
        "rainbow_bridge_noon",
        "tokyo_skytree"
    ]
    
    // MARK: - View lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardController = StickerBoardViewController(model: boardModel)
        
        // StickerBoardViewControllerを子ViewControllerとして追加
        addChild(boardController)
        boardContainer.addSubview(boardController.view)
        boardController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            boardContainer.topAnchor.constraint(equalTo: boardController.view.topAnchor),
            boardContainer.bottomAnchor.constraint(equalTo: boardController.view.bottomAnchor),
            boardContainer.leftAnchor.constraint(equalTo: boardController.view.leftAnchor),
            boardContainer.rightAnchor.constraint(equalTo: boardController.view.rightAnchor),
        ])
        boardController.didMove(toParent: self)
    }
    
    
    @IBAction func onTapAdd(_ sender: Any) {
        let center = CGPoint(x: (-100...100).randomElement()!, y: (-100...100).randomElement()!)
        let sticker = StickerModel(imageIdentifier: imageIdentifiers.randomElement()!, center: center, width: 300, angle: .zero)
        
        print("new sticker spawn at \(center)")
        boardController.addSticker(sticker)
    }
    
    
    @IBAction func onTapEncode(_ sender: Any) {
        do {
            let encodedModel = try JSONEncoder().encode(boardModel)
            lastEncodedData = encodedModel
        } catch {
            print(error)
        }
    }
    
    @IBAction func onTapDecode(_ sender: Any) {
        guard let lastEncodedData = lastEncodedData else {return}
        do {
            let decodedBoard = try JSONDecoder().decode(StickerBoardModel.self, from: lastEncodedData)
            print("\(decodedBoard.stickers.count)個のステッカーをデコードしたけどこれどうやってモデルに戻すの")
        } catch {
            print(error)
        }
    }
    
}

