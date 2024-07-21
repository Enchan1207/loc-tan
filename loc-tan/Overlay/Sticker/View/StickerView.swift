//
//  StickerView.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/20.
//

import UIKit

class StickerView: UIView {
    
    let stickerImage: UIImage
    
    private var centerPoint: CGPoint = .zero
    
    private var widthConstraint = NSLayoutConstraint()
    
    private var centerXConstraint = NSLayoutConstraint()
    
    private var centerYConstraint = NSLayoutConstraint()
    
    override var canBecomeFirstResponder: Bool {true}
    
    // MARK: - Initializing
    
    init(frame: CGRect, image: UIImage){
        self.stickerImage = image
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        guard let stickerImage = coder.decodeObject(forKey: "image") as? UIImage else {return nil}
        self.stickerImage = stickerImage
        super.init(coder: coder)
        setup()
    }
    
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(stickerImage, forKey: "image")
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(stickerImage, forKey: "image")
    }
    
    private func setup(){
        let stickerImageView = UIImageView(image: stickerImage)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(stickerImageView)
        stickerImageView.translatesAutoresizingMaskIntoConstraints = false
        
        // 親ビューに張り付かせる
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: stickerImageView.topAnchor),
            bottomAnchor.constraint(equalTo: stickerImageView.bottomAnchor),
            leftAnchor.constraint(equalTo: stickerImageView.leftAnchor),
            rightAnchor.constraint(equalTo: stickerImageView.rightAnchor),
        ])
        
        // アスペクト比を固定する
        let aspectRatio: CGFloat
        if let imageSize = stickerImageView.image?.size {
            aspectRatio = imageSize.width / imageSize.height
        }else{
            aspectRatio = 1.0
        }
        stickerImageView.widthAnchor.constraint(equalTo: stickerImageView.heightAnchor, multiplier: aspectRatio).isActive = true
        
        // 幅を設定する
        setWidth(0)
        
        // アクティベート枠の設定
        layer.borderWidth = 2.0
        layer.borderColor = UIColor.clear.cgColor
    }
    
    // MARK: - Status modification
    
    @MainActor
    func setStatusRing(_ isActive: Bool) async {
        let ringColor: UIColor = isActive ? .red : .clear
        let duration = 0.2
        await UIView.animate(withDuration: duration) {
            self.layer.borderColor = ringColor.cgColor
        }
    }
    
    // MARK: - View geometry
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview = self.superview else {return}
        
        // 中心座標の制約を再構成する
        NSLayoutConstraint.deactivate([centerXConstraint, centerYConstraint])
        setCenter(centerPoint)
    }
    
    func setWidth(_ width: CGFloat){
        if widthConstraint.isActive {
            widthConstraint.constant = width
        } else {
            widthConstraint = widthAnchor.constraint(equalToConstant: width)
            widthConstraint.isActive = true
        }
        layoutIfNeeded()
    }
    
    func setCenter(_ center: CGPoint){
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
    /// - Parameter angle: 角度
    /// - Warning: アフィン変換行列が置き換えられます。スケール等の情報は失われます。
    func setAngle(_ angle: CGFloat){
        transform = CGAffineTransform(rotationAngle: angle)
    }
    
}
