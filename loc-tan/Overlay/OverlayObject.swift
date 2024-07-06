//
//  OverlayObject.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/30.
//

import UIKit

/// ファインダー上にオーバーレイして表示され、ユーザにより移動・回転・拡縮できるビュー
class OverlayObject: UIView {
    
    // MARK: - Properties
    
    /// オーバーレイ画像
    let overlayImage: UIImage
    
    /// デリゲート
    weak var delegate: OverlayObjectDelegate?
    
    /// 自身が操作対象になっているかどうか
    private (set) public var isActive: Bool = false {
        didSet {
            print(isActive ? "focused" : "unfocused")
        }
    }
    
    /// 最後のパンジェスチャでの移動量
    private var gestureTranslation: CGPoint = .zero
    
    /// 最後のピンチジェスチャでのスケール増加量
    private var gestureScale: CGFloat = 1.0
    
    /// 最後のローテートジェスチャでの角度増加量
    private var gestureRotation: CGFloat = 0.0
    
    /// オブジェクトの中心位置
    var currentCenter: CGPoint {
        .init(x: centerXConstraint.constant, y: centerYConstraint.constant)
    }
    
    /// オブジェクトのサイズ
    var currentSize: CGSize {
        .init(width: widthConstraint.constant, height: bounds.height)
    }
    
    /// オブジェクトの角度
    private (set) public var currentTilt: CGFloat = 0.0
    
    override var canBecomeFirstResponder: Bool { true }
    
    // MARK: - GUI Components
    
    /// 画像を保持するビュー
    private let contentView: UIImageView
    
    /// ステータスリングを表示するビュー
    private let statusRingView: UIView
    
    /// x軸中心制約
    private var centerXConstraint = NSLayoutConstraint()
    
    /// y軸中心制約
    private var centerYConstraint = NSLayoutConstraint()
    
    /// 幅制約
    private var widthConstraint = NSLayoutConstraint()
    
    // MARK: - Initializers
    
    /// 表示する画像を渡して初期化
    /// - Parameter image: オーバーレイする画像
    init(image: UIImage){
        overlayImage = image
        contentView = .init(image: overlayImage)
        statusRingView = .init(frame: .zero)
        
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        overlayImage = (coder.decodeObject(forKey: "overlayImage") as? UIImage) ?? .init(systemName: "photo")!
        contentView = .init(image: overlayImage)
        statusRingView = .init(frame: .zero)
        
        super.init(coder: coder)
        setup()
    }
    
    override func encode(with coder: NSCoder) {
        coder.encode(overlayImage, forKey: "overlayImage")
        super.encode(with: coder)
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        coder.encode(overlayImage, forKey: "overlayImage")
        super.encodeRestorableState(with: coder)
    }
    
    /// ビューを構成する
    private func setup(){
        // サブビュー
        configureSubviews()
        
        // ジェスチャ
        configureGestures()
    }
    
    /// サブビューの構成
    private func configureSubviews(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isUserInteractionEnabled = true
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        let ringWeight: CGFloat = 2
        statusRingView.translatesAutoresizingMaskIntoConstraints = false
        statusRingView.layer.borderWidth = ringWeight
        addSubview(statusRingView)
        
        let preferredAspectRatio = overlayImage.size.width / overlayImage.size.height
        
        NSLayoutConstraint.activate([
            // ビュー自体のアス比を渡された画像のそれに準拠させる
            widthAnchor.constraint(equalTo: heightAnchor, multiplier: preferredAspectRatio),
            
            // contentViewをviewの中心からいっぱいに広げる
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leftAnchor.constraint(equalTo: leftAnchor),
            contentView.rightAnchor.constraint(equalTo: rightAnchor),
            
            // statusRingViewを(枠線のマージンを確保しつつ)いっぱいに広げる
            statusRingView.topAnchor.constraint(equalTo: topAnchor, constant: ringWeight / 2),
            statusRingView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -ringWeight / 2),
            statusRingView.leftAnchor.constraint(equalTo: leftAnchor, constant: ringWeight / 2),
            statusRingView.rightAnchor.constraint(equalTo: rightAnchor, constant: -ringWeight / 2),
        ])
    }
    
    /// ジェスチャの設定
    private func configureGestures(){
        // タップ
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleGesture))
        self.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - View lifecycles
    
    override func didMoveToSuperview() {
        // 制約を構成し、有効化
        centerXConstraint = centerXAnchor.constraint(equalTo: superview!.centerXAnchor)
        centerYConstraint = centerYAnchor.constraint(equalTo: superview!.centerYAnchor)
        widthConstraint = widthAnchor.constraint(equalToConstant: 400)
        NSLayoutConstraint.activate([
            centerXConstraint, centerYConstraint, widthConstraint
        ])
        setNeedsLayout()
    }
    
    // MARK: - Methods
    
    @objc func handleGesture(_ gesture: UIGestureRecognizer){
        switch gesture {
            
        case let pan as UIPanGestureRecognizer:
            switch pan.state {
            case .began:
                beginTranslation()
                fallthrough
            case .changed:
                setTranslation(pan.translation(in: superview))
            case .ended:
                endTranslation()
            case .cancelled:
                cancelTranslation()
            default:
                break
            }
            pan.setTranslation(.zero, in: self)
        
        case let pinch as UIPinchGestureRecognizer:
            switch pinch.state {
            case .began:
                beginScale()
                fallthrough
            case .changed:
                setScale(pinch.scale)
            case .ended:
                endScale()
            case .cancelled:
                cancelScale()
            default:
                break
            }
            pinch.scale = 1.0
        
        case let rot as UIRotationGestureRecognizer:
            switch rot.state {
            case .began:
                beginRotate()
                fallthrough
            case .changed:
                setRotate(rot.rotation)
            case .ended:
                endRotate()
            case .cancelled:
                cancelRotate()
            default:
                break
            }
            rot.rotation = 0.0
            
        case is UITapGestureRecognizer:
            // デリゲートに通知
            if !isActive {
                delegate?.didRequireActivate(self)
            }
            
        default:
            break
        }
        
    }
    
    /// オブジェクトの状態を設定
    /// - Parameter state: 状態
    @MainActor
    func setActivationState(_ state: Bool) async {
        let ringColor: UIColor = state ? .red : .clear
        let duration = 0.2
        await UIView.animate(withDuration: duration) {
            self.statusRingView.layer.borderColor = ringColor.cgColor
        }
        isActive = state
    }
    
    // MARK: - Gesture handling
    
    /// オブジェクトの移動を開始する
    @MainActor
    private func beginTranslation(){
        gestureTranslation = .zero
    }
    
    /// オブジェクトの変位を設定する
    /// - Parameter diff: 変位量
    @MainActor
    private func setTranslation(_ diff: CGPoint){
        gestureTranslation += diff
        center += diff
    }
    
    /// オブジェクトの移動を完了する
    /// - Note: この関数によりレイアウト制約が更新されます。
    @MainActor
    private func endTranslation(){
        // 累積変位量を制約に加算し、変位量をリセット
        centerXConstraint.constant += gestureTranslation.x
        centerYConstraint.constant += gestureTranslation.y
        gestureTranslation = .zero
        setNeedsLayout()
    }
    
    /// オブジェクトの移動を取り消す
    @MainActor
    private func cancelTranslation(){
        // 累積変位量の分だけcenterを戻す
        center -= gestureTranslation
        gestureTranslation = .zero
    }
    
    /// オブジェクトの拡大を開始する
    @MainActor
    private func beginScale(){
        gestureScale = 1.0
    }
    
    /// オブジェクトの拡大倍率を設定する
    /// - Parameter diff: 倍率
    @MainActor
    private func setScale(_ diff: CGFloat){
        // TODO: 枠線消す?
        gestureScale *= diff
        transform = transform.scaledBy(x: diff, y: diff)
    }
    
    /// オブジェクトの拡大を完了する
    /// - Note: この関数によりレイアウト制約が更新されます。
    @MainActor
    private func endScale(){
        // TODO: 枠線再表示?
        widthConstraint.constant *= gestureScale
        transform = transform.scaledBy(x: 1.0 / gestureScale, y: 1.0 / gestureScale)
        gestureScale = 1.0
        setNeedsLayout()
    }
    
    /// オブジェクトの拡大を取り消す
    @MainActor
    private func cancelScale(){
        widthConstraint.constant /= gestureScale
        gestureScale = 1.0
    }
    
    /// オブジェクトの回転を開始する
    @MainActor
    private func beginRotate(){
        gestureRotation = 0.0
    }
    
    /// オブジェクトの回転角度を設定する
    /// - Parameter diff: 角度移動量
    @MainActor
    private func setRotate(_ diff: CGFloat){
        gestureRotation += diff
        transform = transform.rotated(by: diff)
    }
    
    /// オブジェクトの回転を終了する
    @MainActor
    private func endRotate(){
        let newTilt = (currentTilt + gestureRotation).truncatingRemainder(dividingBy: 2 * .pi)
        currentTilt = newTilt >= 0 ? newTilt : newTilt + 2 * .pi
        gestureRotation = 0.0
    }
    
    /// オブジェクトの回転を取り消す
    @MainActor
    private func cancelRotate(){
        transform = transform.rotated(by: -gestureRotation)
        gestureRotation = 0.0
    }
    
}
