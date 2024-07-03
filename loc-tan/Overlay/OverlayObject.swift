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
    
    /// 最後のパンジェスチャでの移動量
    private var gestureTranslation: CGPoint = .zero
    
    /// 最後のピンチジェスチャでのスケール増加量
    private var gestureScale: CGFloat = 1.0
    
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
        centerXConstraint.isActive = true
        centerYConstraint = centerYAnchor.constraint(equalTo: superview!.centerYAnchor)
        centerYConstraint.isActive = true
        widthConstraint = widthAnchor.constraint(equalToConstant: 400)
        widthConstraint.isActive = true
        setNeedsLayout()
    }
    
    // MARK: - Gestures
    
    @objc private func handleGesture(_ gesture: UIGestureRecognizer){
        switch gesture {
            
        case is UITapGestureRecognizer:
            // デリゲートに通知
            if !isActive {
                delegate?.didRequireActivate(self)
            }
            
        default:
            break
        }
        
    }
    
    // MARK: - Methods
    
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
    
    /// オブジェクトの変位を設定する
    /// - Parameter diff: 変位量
    @MainActor
    func setTranslation(_ diff: CGPoint){
        gestureTranslation += diff
        center += diff
    }
    
    /// オブジェクトの移動を完了する
    /// - Note: この関数によりレイアウト制約が更新されます。
    @MainActor
    func endTranslation(){
        // 累積変位量を制約に加算し、変位量をリセット
        centerXConstraint.constant += gestureTranslation.x
        centerYConstraint.constant += gestureTranslation.y
        gestureTranslation = .zero
        setNeedsLayout()
    }
    
    /// オブジェクトの移動を取り消す
    @MainActor
    func cancelTranslation(){
        // 累積変位量の分だけcenterを戻す
        center -= gestureTranslation
        gestureTranslation = .zero
    }
    
    /// オブジェクトを拡大する
    /// - Parameter diff: 倍率
    @MainActor
    func setScale(_ diff: CGFloat){
        // TODO: 枠線消す?
        gestureScale *= diff
        transform = transform.scaledBy(x: diff, y: diff)
    }
    
    /// オブジェクトの拡大を完了する
    /// - Note: この関数によりレイアウト制約が更新されます。
    @MainActor
    func endScale(){
        // TODO: 枠線再表示?
        widthConstraint.constant *= gestureScale
        transform = transform.scaledBy(x: 1.0 / gestureScale, y: 1.0 / gestureScale)
        gestureScale = 1.0
        setNeedsLayout()
    }
    
    /// オブジェクトの拡大を取り消す
    @MainActor func cancelScale(){
        widthConstraint.constant /= gestureScale
        gestureScale = 1.0
    }
    
}
