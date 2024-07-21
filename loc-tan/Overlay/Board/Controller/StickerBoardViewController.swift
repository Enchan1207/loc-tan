//
//  StickerBoardViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/20.
//

import UIKit

class StickerBoardViewController: UIViewController {
    
    private let model: StickerBoardModel
    
    private var controllers: [StickerViewController] = []
    
    private var activeStickerController: StickerViewController?
    
    // MARK: - Initializing
    
    init(model: StickerBoardModel) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        // TODO: 実装
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        let stickerBoard = StickerBoardView(frame: .zero)
        self.view = stickerBoard
        
        // モデルが持つステッカーの情報をもとにステッカーのビューとコントローラを構成
        model.stickers.forEach({self.addSticker($0)})
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
    
    func addSticker(_ sticker: StickerModel){
        // ステッカーコントローラの構成
        let stickerController = StickerViewController(model: sticker)
        stickerController.delegate = self
        
        // ボードに追加
        model.stickers.append(sticker)
        controllers.append(stickerController)
        
        // 子VCとして追加
        addChild(stickerController)
        view.addSubview(stickerController.view)
        stickerController.didMove(toParent: self)
    }
    
    func removeSticker(){
        // TODO: 実装
    }
    
    private func switchActiveSticker(to newSticker: StickerViewController) async {
        // 既存のステッカーを非活性化し、新たなステッカーを活性化
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.activeStickerController?.deactivate()
            }
            
            group.addTask {
                await newSticker.activate()
            }
        }
        
        // 制御を置き換える
        activeStickerController = newSticker
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
        // FIXME: 終わっていないうちから別のステッカーに切り替えるのは危険では?
        Task {
            await switchActiveSticker(to: sticker)
        }
    }
    
}
