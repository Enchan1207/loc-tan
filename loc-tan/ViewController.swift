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
    
    @IBOutlet private weak var boardContainer: UIView!
    
    private let images: [UIImage] = [
        "dive_stage",
        "rainbow_bridge_night",
        "rainbow_bridge_noon",
        "tokyo_skytree"
    ].compactMap({.init(named: $0)})
    
    // MARK: - View lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        boardController = StickerBoardViewController(model: boardModel)
        
        // StickerBoardViewControllerを子ViewControllerとして追加
        addChild(boardController)
        boardContainer.addSubview(boardController.view)
        boardController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            boardContainer.widthAnchor.constraint(equalTo: boardController.view.widthAnchor),
            boardContainer.heightAnchor.constraint(equalTo: boardController.view.heightAnchor),
        ])
        boardController.didMove(toParent: self)
    }
    
    
    @IBAction func onTapAdd(_ sender: Any) {
        let center = CGPoint(x: (-100...100).randomElement()!, y: (-100...100).randomElement()!)
        let sticker = StickerModel(image: images.randomElement()!, center: center, width: 300, angle: 0)
        
        print("new sticker spawn at \(center)")
        boardController.addSticker(sticker)
    }
    
}

