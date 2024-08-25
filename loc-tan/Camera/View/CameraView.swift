//
//  CameraView.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/08/04.
//

import UIKit
import AVKit

class CameraView: UIView {
    
    /// キャプチャプレビューレイヤ
    let videoPreviewLayer = AVCaptureVideoPreviewLayer()
    
    /// 現在フォーカスが当たっている点の座標
    var focusPoint: CGPoint? {
        didSet {
            if focusPoint != nil {
                updateFocusFrame(to: focusPoint!)
            }else{
                removeFocusFrame()
            }
        }
    }
    
    /// プレビュー対象のキャプチャセッション
    var session: AVCaptureSession? {
        get { videoPreviewLayer.session }
        set { videoPreviewLayer.session = newValue }
    }
    
    /// プレビューViewのアスペクト比
    var aspectRatio: AspectRatio {
        // TODO: アス比変更をアニメーションしてもいいか
        didSet {
            // フォーカスリングを削除
            self.focusPoint = nil
            
            // 比率制約を再設定
            aspectConstraint.isActive = false
            aspectConstraint = heightAnchor.constraint(equalTo: widthAnchor, multiplier: aspectRatio.rawValue)
            aspectConstraint.isActive = true
            setNeedsLayout()
        }
    }
    
    // MARK: - Private
    
    // グリッド
    private var grid = CAShapeLayer()
    
    /// フォーカス枠
    private var focusFrame = CAShapeLayer()
    
    /// ビューのアス比制約
    private var aspectConstraint = NSLayoutConstraint()
    
    // MARK: - Initializing
    
    init(frame: CGRect, aspectRatio: AspectRatio) {
        self.aspectRatio = aspectRatio
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        self.aspectRatio = .wide
        super.init(coder: coder)
        setup()
    }
    
    private func setup(){
        // カメラプレビューレイヤを生成・割り当て
        videoPreviewLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(videoPreviewLayer)
        
        // グリッド枠を初期化
        initGrid()
        layer.addSublayer(grid)
        
        // フォーカス枠を初期化
        initFocusFrame()
        layer.addSublayer(focusFrame)
        
        // アス比制約を初期化
        aspectConstraint = heightAnchor.constraint(equalTo: widthAnchor, multiplier: aspectRatio.rawValue)
        aspectConstraint.isActive = true
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer.frame = bounds
        grid.path = createGridLayer(size: bounds.size, numberOfRows: 3, numberOfCols: 3)
    }
    
    override func didMoveToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Methods
    
    /// フォーカス枠を初期化する
    private func initFocusFrame(){
        focusFrame = .init()
        focusFrame.strokeColor = UIColor.systemOrange.cgColor
        focusFrame.lineWidth = 1.5
        focusFrame.fillColor = UIColor.clear.cgColor
        focusFrame.opacity = 0.0
    }
    
    /// グリッドを初期化する
    private func initGrid(){
        grid = .init()
        grid.strokeColor = UIColor.white.cgColor
        grid.lineWidth = 0.9
        grid.fillColor = UIColor.clear.cgColor
        grid.opacity = 0.9
    }
    
    /// グリッドレイヤを作成して返す
    /// - Parameters:
    ///   - size: 領域の大きさ
    ///   - rows: 縦区画数
    ///   - cols: 横区画数
    /// - Returns: 作成したグリッドレイヤ
    /// - Note: 区画数の数で分割されます(引かれる線分は指定した値-1本になります)。
    private func createGridLayer(size: CGSize, numberOfRows rows: UInt, numberOfCols cols: UInt) -> CGPath {
        let path = CGMutablePath()
        guard rows > 1, cols > 1 else {return path}
        
        // 1区画あたりの幅と高さを計算
        let unitWidth = size.width / .init(cols)
        let unitHeight = size.height / .init(rows)
        
        // 引く線分の座標リストを計算
        let lineXPositions = (1..<cols).map({unitWidth * .init($0)})
        let lineYPositions = (1..<rows).map({unitHeight * .init($0)})
        
        // それぞれについて move -> addLine
        lineXPositions.forEach({x in
            path.move(to: .init(x: x, y: 0))
            path.addLine(to: .init(x: x, y: size.height))
        })
        lineYPositions.forEach({y in
            path.move(to: .init(x: 0, y: y))
            path.addLine(to: .init(x: size.width, y: y))
        })
        
        return path
    }
    
    /// フォーカス枠の位置を更新する
    /// - Parameter layerPoint: レイヤ上のフォーカス位置
    private func updateFocusFrame(to layerPoint: CGPoint){
        // TODO: この辺りは完全にデザインの問題なので、いつかちゃんとやる
        let size: CGFloat = 100
        let rect = CGRect(x: layerPoint.x - size / 2, y: layerPoint.y - size / 2, width: size, height: size)
        focusFrame.path = UIBezierPath(rect: rect).cgPath
        
        let animation = makeOpacityAnimation(from: 0.0, to: 1.0, duration: 0.3)
        focusFrame.add(animation, forKey: "frame_visibility")
    }
    
    /// フォーカス枠を削除する
    private func removeFocusFrame(){
        let animation = makeOpacityAnimation(from: 1.0, to: 0.0, duration: 0.3)
        focusFrame.add(animation, forKey: "frame_visibility")
    }
    
    private func makeOpacityAnimation(from: CGFloat, to: CGFloat, duration: CFTimeInterval) -> CAAnimation {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = from
        animation.toValue = to
        animation.duration = duration
        animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        return animation
    }
    
}
