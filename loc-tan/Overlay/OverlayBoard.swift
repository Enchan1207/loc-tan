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
            UIPinchGestureRecognizer(target: self, action: #selector(handleGesture)),
            UIRotationGestureRecognizer(target: self, action: #selector(handleGesture))
        ]
        gestures.forEach { gesture in
            gesture.delegate = self
            self.addGestureRecognizer(gesture)
        }
    }
    
    // MARK: - Gestures
    
    @objc private func handleGesture(_ gesture: UIGestureRecognizer){
        // 操作対象のオブジェクトがなければ何もしない
        guard let currentObject = currentActivatedObject else {return}
        
        switch gesture {
            
        case let pan as UIPanGestureRecognizer:
            switch pan.state {
            case _ where [.began, .changed].contains(pan.state):
                currentObject.setTranslation(pan.translation(in: superview))
            case .ended:
                currentObject.endTranslation()
            case .cancelled:
                currentObject.cancelTranslation()
            default:
                break
            }
            pan.setTranslation(.zero, in: self)
            
        case let pinch as UIPinchGestureRecognizer:
            switch pinch.state {
            case .began:
                fallthrough
            case .changed:
                currentObject.setScale(pinch.scale)
            case .ended:
                currentObject.endScale()
            case .cancelled:
                currentObject.cancelScale()
            default:
                break
            }
            pinch.scale = 1.0
        
        case let rot as UIRotationGestureRecognizer:
            currentObject.transform = currentObject.transform.rotated(by: rot.rotation)
            rot.rotation = 0.0
            
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
