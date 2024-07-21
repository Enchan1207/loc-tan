//
//  StickerView.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/20.
//

import UIKit

class StickerView: UIView {
    
    let stickerImage: UIImageView
    
    private var widthConstraint = NSLayoutConstraint()
    
    private var centerXConstraint = NSLayoutConstraint()
    
    private var centerYConstraint = NSLayoutConstraint()
    
    // MARK: - Initializing
    
    init(frame: CGRect, image: UIImage){
        self.stickerImage = .init(image: image)
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        // TODO: 実装
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stickerImage)
        stickerImage.translatesAutoresizingMaskIntoConstraints = false
        
        // 親ビューに張り付かせる
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: stickerImage.topAnchor),
            bottomAnchor.constraint(equalTo: stickerImage.bottomAnchor),
            leftAnchor.constraint(equalTo: stickerImage.leftAnchor),
            rightAnchor.constraint(equalTo: stickerImage.rightAnchor),
        ])
        
        // アスペクト比を固定する
        let aspectRatio: CGFloat
        if let imageSize = stickerImage.image?.size {
            aspectRatio = imageSize.width / imageSize.height
        }else{
            aspectRatio = 1.0
        }
        stickerImage.widthAnchor.constraint(equalTo: stickerImage.heightAnchor, multiplier: aspectRatio).isActive = true
        
        // 幅を設定する
        setWidth(0)
        
        // アクティベート枠の設定
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.clear.cgColor
    }
    
    // MARK: - Status modification
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview = self.superview else {return}
        
        // 中心座標の制約を再構成する
        NSLayoutConstraint.deactivate([centerXConstraint, centerYConstraint])
        centerXConstraint = centerXAnchor.constraint(equalTo: superview.centerXAnchor)
        centerYConstraint = centerYAnchor.constraint(equalTo: superview.centerYAnchor)
        NSLayoutConstraint.activate([centerXConstraint, centerYConstraint])
    }
    
    @MainActor
    func setStatusRing(_ isActive: Bool) async {
        let ringColor: UIColor = isActive ? .red : .clear
        let duration = 0.2
        await UIView.animate(withDuration: duration) {
            self.layer.borderColor = ringColor.cgColor
        }
    }
    
    func setWidth(_ width: CGFloat){
        widthConstraint = widthAnchor.constraint(equalToConstant: width)
        widthConstraint.isActive = true
        layoutIfNeeded()
    }
    
    func setCenter(_ center: CGPoint){
        guard centerXConstraint.isActive && centerYConstraint.isActive else {
            // TODO: Logging
            return
        }
        
        centerXConstraint.constant = center.x
        centerYConstraint.constant = center.y
        layoutIfNeeded()
    }
    
    /// 角度を設定する
    /// - Parameter angle: 角度
    /// - Warning: アフィン変換行列が置き換えられます。スケール等の情報は失われます。
    func setAngle(_ angle: CGFloat){
        transform = CGAffineTransform(rotationAngle: angle)
    }
    
}
