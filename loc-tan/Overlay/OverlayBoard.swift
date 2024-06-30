//
//  OverlayBoard.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/30.
//

import UIKit

/// OverlayObjectを配置するベースとなるビュー
class OverlayBoard: UIView {
    
    // MARK: - Properties
    
    /// 現在操作対象となっているオブジェクト
    private var currentActivatedObject: OverlayObject? = nil
    
    // MARK: - Initializers
    
    init(){
        super.init(frame: .null)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    /// ビューを構成する
    private func setup() {
        // レイアウト制約
        configureLayoutConstraints()
        
        // ジェスチャ
        configureGestures()
    }
    
    /// レイアウト制約の設定
    private func configureLayoutConstraints(){
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// ジェスチャの設定
    private func configureGestures(){
        let gestures = [
            UIPanGestureRecognizer(target: self, action: #selector(handleGesture)),
            UIPinchGestureRecognizer(target: self, action: #selector(handleGesture))
        ]
        gestures.forEach { gesture in
            gesture.delegate = self
            self.addGestureRecognizer(gesture)
        }
    }
    
    // MARK: - Gestures
    
    @objc private func handleGesture(_ gesture: UIGestureRecognizer){
        guard let currentObject = currentActivatedObject,
              [.began, .changed].contains(gesture.state) else {return}
        
        switch gesture {
            
        case let pan as UIPanGestureRecognizer:
            let translation = pan.translation(in: superview)
            currentObject.center = CGPoint(x: currentObject.center.x + translation.x, y: currentObject.center.y + translation.y)
            pan.setTranslation(.zero, in: self)
            
        case let pinch as UIPinchGestureRecognizer:
            currentObject.transform = currentObject.transform.scaledBy(x: pinch.scale, y: pinch.scale)
            pinch.scale = 1.0
            
        default:
            break
        }
        
    }
    
    // MARK: - Methods
    
    /// オーバーレイオブジェクトを追加する
    /// - Parameter overlayObject: 追加するオブジェクト
    func addObject(_ overlayObject: OverlayObject){
        overlayObject.delegate = self
        addSubview(overlayObject)
        Task {
            await switchFocus(to: overlayObject)
        }
    }
    
    /// 画像をもとにオーバーレイオブジェクトを追加する
    /// - Parameter image: オブジェクトに載せる画像
    func addObject(_ image: UIImage){
        addObject(.init(image: image))
    }
    
    /// フォーカスを移動する
    /// - Parameter object: 操作対象にしたいオブジェクト
    @MainActor
    private func switchFocus(to object: OverlayObject) async {
        guard self.subviews.contains(object) else {return}
        bringSubviewToFront(object)
        await withTaskGroup(of: Void.self) { [weak self] group in
            guard let `self` = self else {return}
            group.addTask { await self.currentActivatedObject?.setActivationState(false) }
            group.addTask { await object.setActivationState(true) }
        }
        currentActivatedObject = object
    }
    
}

extension OverlayBoard: OverlayObjectDelegate {
    
    func didRequireActivate(_ sender: OverlayObject) {
        Task {
            await switchFocus(to: sender)
        }
    }
    
}

extension OverlayBoard: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
}
