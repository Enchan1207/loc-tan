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
    
    @MainActor private func switchActiveSticker(to newSticker: StickerViewController?) {
        if let newSticker = newSticker {
            view.bringSubviewToFront(newSticker.view)
            boardModel.switchTarget(to: newSticker.stickerModel)
        }
        activeStickerController = newSticker
    }
    
    /// アクティブなステッカーを全画面に拡大する
    func expandCurrentStickerToFullScreen(){
        guard let activeStickerModel = activeStickerController?.stickerModel else {return}
        
        // 角度をスナップして中央に移動
        activeStickerModel.angle = activeStickerModel.angle.snapedToCross
        activeStickerModel.center = .zero
        
        // 回転角度を考慮したステッカーのアスペクト比を計算
        let isRotated = (45...135).contains(abs(activeStickerModel.angle.degrees))
        let stickerImageSize = activeStickerModel.image.size
        let stickerAspectRatioOnScreen: AspectRatio = isRotated ? .custom(stickerImageSize.height / stickerImageSize.width) : .custom(stickerImageSize.width / stickerImageSize.height)
        
        // ビューをはみ出ない最大サイズを取得し、設定
        let maxStickerSizeOnScreen = view.bounds.size.maxFitSize(at: stickerAspectRatioOnScreen)
        activeStickerModel.width = isRotated ? maxStickerSizeOnScreen.height : maxStickerSizeOnScreen.width
    }
    
    /// ステッカーを十字方向にスナップさせ、さらに回転させる
    /// - Parameter diff: 変化量
    func rotateCurrentSticker(diff: Angle){
        guard let activeStickerModel = activeStickerController?.stickerModel else {return}
        activeStickerModel.angle = activeStickerModel.angle.snapedToCross + diff
    }
    
    // MARK: - Gestures
    
    @objc private func handleGesture(_ gesture: UIGestureRecognizer){
        switch gesture {
        case let pan as UIPanGestureRecognizer:
            activeStickerController?.onPanSticker(pan)
            
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
        switchActiveSticker(to: controller)
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
        switchActiveSticker(to: sticker)
    }
    
    func stickerViewDidRequireDeletion(_ sticker: StickerViewController){
        Task {
            await sticker.updateVisibility(false)
            boardModel.remove(sticker.stickerModel)
        }
    }
    
}

extension StickerBoardViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
