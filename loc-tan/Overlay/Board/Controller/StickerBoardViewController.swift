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
            let tasks: [@Sendable () async -> Void] = controllers.map({controller in
                {await controller == newSticker ? controller.activate() : controller.deactivate()}
            })
            tasks.forEach({group.addTask(operation: $0)})
        }
        
        // 制御を置き換える
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
        let stickerAspectRatioOnScreen = isRotated ? stickerImageSize.height / stickerImageSize.width : stickerImageSize.width / stickerImageSize.height
        
        // ビューをはみ出ない最大サイズを取得
        let maxStickerSizeOnScreen: CGSize = ({viewSize, aspectRatio in
            // 幅を固定した場合の高さがビュー自体の高さを上回るなら、ビューの高さから幅を再計算する
            // そうでなければ、アスペクト比に従って幅から高さを計算する
            if (viewSize.width / aspectRatio) > viewSize.height {
                .init(width: viewSize.height * aspectRatio, height: viewSize.height)
            } else {
                .init(width: viewSize.width, height: viewSize.height / aspectRatio)
            }
        })(view.bounds.size, stickerAspectRatioOnScreen)
        
        // 設定
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
    
    func stickerBoard(_ board: StickerBoardModel, didChangeHighlightState shouldHighlight: Bool) {
        // ステッカーのハイライトが有効なら、アクティブなステッカーをハイライトし、そうでないものを非ハイライトする
        // そうでなければ、すべてのステッカーをハイライトする
        Task {
            await withTaskGroup(of: Void.self) { group in
                let tasks: [@Sendable () async -> Void] = controllers.map({controller in
                    {await controller.updateHighlightedState(shouldHighlight ? controller == self.activeStickerController : true)}
                })
                tasks.forEach({group.addTask(operation: $0)})
            }
        }
    }
    
    func stickerBoard(_ board: StickerBoardModel, didChangeStickersOpacity opacity: Float, animated: Bool) {
        // アニメーションがいらないなら簡単なんですよ
        guard animated else {
            controllers.forEach({$0.updateOpacity(opacity)})
            return
        }
        
        Task {
            await withTaskGroup(of: Void.self) { group in
                let tasks: [@Sendable () async -> Void] = controllers.map({controller in
                    {await controller.updateOpacity(opacity)}
                })
                tasks.forEach({group.addTask(operation: $0)})
            }
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
