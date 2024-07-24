//
//  StickerBoardViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/20.
//

import UIKit

class StickerBoardViewController: UIViewController {
    
    private let boardModel: StickerBoardModel
    
    private var controllers: [StickerViewController] = []
    
    private var activeStickerController: StickerViewController?
    
    // MARK: - Initializing
    
    init(boardModel: StickerBoardModel) {
        self.boardModel = boardModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        guard let model = coder.decodeObject(forKey: "model") as? StickerBoardModel else {return nil}
        self.boardModel = model
        super.init(coder: coder)
    }
    
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(boardModel, forKey: "model")
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(boardModel, forKey: "model")
    }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        let stickerBoard = StickerBoardView(frame: .zero)
        self.view = stickerBoard
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // モデルが持つステッカーの情報をもとにステッカーのビューとコントローラを構成
        boardModel.stickers.forEach({self.addSticker($0)})
        
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
    
    // MARK: - Add/remove stickers
    
    func addSticker(_ sticker: StickerModel){
        // ステッカーコントローラの構成
        let stickerController = StickerViewController(stickerModel: sticker)
        stickerController.delegate = self
        
        // ボードに追加
        boardModel.add(sticker)
        controllers.append(stickerController)
        
        // 子VCとして追加
        addChild(stickerController)
        view.addSubview(stickerController.view)
        stickerController.didMove(toParent: self)
        
        // 操作対象にする
        Task {
            await switchActiveSticker(to: stickerController)
        }
    }
    
    private func removeSticker(_ stickerController: StickerViewController){
        guard let index = controllers.firstIndex(of: stickerController) else {return}
        stickerController.view.removeFromSuperview()
        boardModel.remove(at: index)
        controllers.remove(at: index)
        if activeStickerController == stickerController {
            activeStickerController = nil
        }
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
            removeSticker(sticker)
        }
    }
    
}

extension StickerBoardViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
