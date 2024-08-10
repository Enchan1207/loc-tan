//
//  StickerBoardViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/20.
//

import UIKit

class StickerBoardViewController: UIViewController {
    
    private let boardModel: StickerBoardModel
    
    private var controllers: [StickerViewController]
    
    private(set) var activeStickerController: StickerViewController?
    
    // MARK: - Initializing
    
    init(boardModel: StickerBoardModel) {
        self.boardModel = boardModel
        
        // ステッカーコントローラを生成しておく
        self.controllers = boardModel.stickers.map({.init(stickerModel: $0)})
        
        super.init(nibName: nil, bundle: nil)
        
        self.boardModel.delegate = self
        self.controllers.forEach({$0.delegate = self})
    }
    
    required init?(coder: NSCoder) {
        // NOTE: このクラス自体をNSCoder経由でインスタンス化することはないだろうという読み
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        self.view = StickerBoardView(frame: .zero)
        
        // ステッカーコントローラの持つビューをこちらに移動
        controllers.forEach(moveStickerToBoard)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ジェスチャを追加
        [UIPanGestureRecognizer.self,
         UIPinchGestureRecognizer.self,
         UIRotationGestureRecognizer.self]
            .map({$0.init(target: self, action: #selector(handleGesture))})
            .forEach({gesture in
                gesture.delegate = self
                self.view.addGestureRecognizer(gesture)
            })
    }
    
    // MARK: - Methods
    
    private func moveStickerToBoard(_ controller: StickerViewController){
        addChild(controller)
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
    }
    
    private func switchActiveSticker(to newSticker: StickerViewController?) async {
        // 制御を引き継ぐ方のステッカーを上に持ってくる
        if let newSticker = newSticker {
            view.bringSubviewToFront(newSticker.view)
        }
        
        // 既存のステッカーを非活性化し、新たなステッカーを活性化
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                await self.activeStickerController?.deactivate()
            }
            
            group.addTask {
                await newSticker?.activate()
            }
        }
        
        // 制御を置き換える
        activeStickerController = newSticker
    }
    
    // MARK: - Gestures
    
    @objc private func handleGesture(_ gesture: UIGestureRecognizer){
        switch gesture {
        case let pan as UIPanGestureRecognizer:
            activeStickerController?.onPanSticker(pan)
            break
            
        case let pinch as UIPinchGestureRecognizer:
            activeStickerController?.onPinchSticker(pinch)
            
        case let rot as UIRotationGestureRecognizer:
            activeStickerController?.onRotateSticker(rot)
            
        default:
            break
        }
    }
    
}

extension StickerBoardViewController: StickerBoardModelDelegate {
    
    func stickerBoard(_ board: StickerBoardModel, didAddSticker sticker: StickerModel) {
        let controller = StickerViewController(stickerModel: sticker)
        controller.delegate = self
        controllers.append(controller)
        moveStickerToBoard(controller)
        
        // 操作対象を切り替える
        Task {
            await switchActiveSticker(to: controller)
        }
    }
    
    func stickerBoard(_ board: StickerBoardModel, didRemoveSticker sticker: StickerModel) {
        guard let controller = controllers.first(where: {$0.stickerModel == sticker}) else {return}
        
        controller.view.removeFromSuperview()
        controller.removeFromParent()
        if activeStickerController == controller {
            activeStickerController = nil
        }
    }
    
}

extension StickerBoardViewController: StickerViewControllerDelegate {
    
    func stickerViewDidRequireActivation(_ sticker: StickerViewController) {
        // FIXME: 終わっていないうちから別のステッカーに切り替えるのは危険では?
        Task {
            await switchActiveSticker(to: sticker)
        }
    }
    
    func stickerViewDidRequireDeletion(_ sticker: StickerViewController){
        // FIXME: アニメーションをここで定義するのはちょっと…
        Task {
            sticker.view.isUserInteractionEnabled = false
            await UIView.animate(withDuration: 0.08) {
                sticker.view.alpha = 0.0
            }
            boardModel.remove(sticker.stickerModel)
        }
    }
    
}

extension StickerBoardViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
