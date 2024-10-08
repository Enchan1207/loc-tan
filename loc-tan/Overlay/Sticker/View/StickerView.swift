//
//  StickerView.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/20.
//

import UIKit

class StickerView: UIView {
    
    private let stickerImageView: UIImageView
    
    /// 操作対象でないときに、ステッカーをグレーアウトさせるためのView
    private let statusEffectView = UIView()
    
    private var centerPoint: CGPoint = .zero
    
    private var widthConstraint = NSLayoutConstraint()
    
    private var centerXConstraint = NSLayoutConstraint()
    
    private var centerYConstraint = NSLayoutConstraint()
    
    override var canBecomeFirstResponder: Bool {true}
    
    // MARK: - Initializing
    
    init(frame: CGRect, image: UIImage){
        self.stickerImageView = .init(image: image)
        super.init(frame: frame)
        setup()
    }
    
    convenience init(frame: CGRect, image: UIImage, center: CGPoint, width: CGFloat, angle: Angle, opacity: Float){
        self.init(frame: frame, image: image)
        updateCenter(center)
        updateWidth(width)
        updateAngle(angle)
        updateOpacity(opacity)
    }
    
    required init?(coder: NSCoder) {
        // NOTE: このクラス自体をNSCoder経由でインスタンス化することはないだろうという読み
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(){
        self.translatesAutoresizingMaskIntoConstraints = false
        updateWidth(0)
        
        setupImageView()
        setupStatusEffectView()
    }
    
    private func setupImageView(){
        self.addSubview(stickerImageView)
        stickerImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: stickerImageView.topAnchor),
            bottomAnchor.constraint(equalTo: stickerImageView.bottomAnchor),
            leftAnchor.constraint(equalTo: stickerImageView.leftAnchor),
            rightAnchor.constraint(equalTo: stickerImageView.rightAnchor),
        ])
        
        // アスペクト比を固定する
        let imageSize = stickerImageView.image!.size
        let aspectRatio = imageSize.width / imageSize.height
        stickerImageView.widthAnchor.constraint(equalTo: stickerImageView.heightAnchor, multiplier: aspectRatio).isActive = true
    }
    
    private func setupStatusEffectView(){
        self.addSubview(statusEffectView)
        statusEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: statusEffectView.topAnchor),
            bottomAnchor.constraint(equalTo: statusEffectView.bottomAnchor),
            leftAnchor.constraint(equalTo: statusEffectView.leftAnchor),
            rightAnchor.constraint(equalTo: statusEffectView.rightAnchor),
        ])
        statusEffectView.backgroundColor = .black.withAlphaComponent(0.5)
        statusEffectView.alpha = 0.0
    }
    
    // MARK: - Status modification
    
    /// ステッカーの表示状態を切り替える
    /// - Parameter isVisible: 表示・非表示
    @MainActor func updateVisibility(_ isVisible: Bool) async {
        let duration = 0.15
        await UIView.animate(withDuration: duration) {
            self.isUserInteractionEnabled = isVisible
            self.alpha = isVisible ? 1.0 : 0.0
        }
    }
    
    /// ハイライト状態を切り替える
    @MainActor func setGrayedOut(_ isGrayedOut: Bool) async {
        let duration = 0.15
        await UIView.animate(withDuration: duration) {
            self.statusEffectView.alpha = isGrayedOut ? 1.0 : 0.0
        }
    }
    
    /// 透明度を設定する
    /// - Parameter opacity: 透明度
    @MainActor func updateOpacity(_ opacity: Float) async {
        let duration = 0.15
        await UIView.animate(withDuration: duration) {
            self.stickerImageView.layer.opacity = opacity
        }
    }
    
    /// 透明度を設定する
    /// - Parameter opacity: 透明度
    @MainActor func updateOpacity(_ opacity: Float) {
        self.stickerImageView.layer.opacity = opacity
    }
    
    // MARK: - View geometry
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // 中心座標の制約を再構成する
        NSLayoutConstraint.deactivate([centerXConstraint, centerYConstraint])
        updateCenter(centerPoint)
    }
    
    func updateWidth(_ width: CGFloat){
        if widthConstraint.isActive {
            widthConstraint.constant = width
        } else {
            widthConstraint = widthAnchor.constraint(equalToConstant: width)
            widthConstraint.isActive = true
        }
        layoutIfNeeded()
    }
    
    func updateCenter(_ center: CGPoint){
        centerPoint = center
        
        // 制約が生きてるなら定数値を変えて戻る
        if centerXConstraint.isActive && centerYConstraint.isActive {
            centerXConstraint.constant = center.x
            centerYConstraint.constant = center.y
            layoutIfNeeded()
            return
        }
        
        // なければ制約自体を構成する
        guard let superview = self.superview else {return}
        centerXConstraint = centerXAnchor.constraint(equalTo: superview.centerXAnchor,constant: centerPoint.x)
        centerYConstraint = centerYAnchor.constraint(equalTo: superview.centerYAnchor,constant: centerPoint.y)
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])
        layoutIfNeeded()
    }
    
    /// 角度を設定する
    /// - Warning: アフィン変換行列が置き換えられます。スケール等の情報は失われます。
    func updateAngle(_ angle: Angle){
        transform = CGAffineTransform(rotationAngle: angle.radians)
    }
    
}
