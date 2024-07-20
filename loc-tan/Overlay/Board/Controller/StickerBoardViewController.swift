//
//  StickerBoardViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/20.
//

import UIKit

class StickerBoardViewController: UIViewController {
    
    private let model: StickerBoardModel
    
    private var controllers: [StickerViewController]
    
    private var activeStickerController: StickerViewController?
    
    // MARK: - Initializing
    
    init(model: StickerBoardModel) {
        self.model = model
        self.controllers = model.stickers.map({.init(model: $0)})
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        // TODO: 実装
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        let stickerBoard = StickerBoardView(frame: .zero)
        
        // TODO: restore stickers from model (passed at initializer)
        
        self.view = stickerBoard
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        [
            UIPanGestureRecognizer(target: self.view, action: #selector(onPanStickerBoard)),
            UIPinchGestureRecognizer(target: self.view, action: #selector(onPinchStickerBoard)),
            UIRotationGestureRecognizer(target: self.view, action: #selector(onRotateStickerBoard))
        ].forEach({self.view.addGestureRecognizer($0)})
    }
    
    // MARK: - Add/remove stickers
    
    func addSticker(){
        // TODO: 実装
    }
    
    func removeSticker(){
        // TODO: 実装
    }

}

extension StickerBoardViewController {
    
    @objc private func onPanStickerBoard(_ gesture: UIPanGestureRecognizer){
        // TODO: 実装
    }
    
    @objc private func onPinchStickerBoard(_ gesture: UIPinchGestureRecognizer){
        // TODO: 実装
    }
    
    @objc private func onRotateStickerBoard(_ gesture: UIPinchGestureRecognizer){
        // TODO: 実装
    }
    
}

extension StickerBoardViewController: StickerViewControllerDelegate {
    
    func stickerViewDidRequireActivation(_ sticker: StickerViewController) {
        // TODO: deselect all stickers and select specified sticker
    }
    
}
