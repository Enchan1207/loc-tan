//
//  MainView.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/08/12.
//

import UIKit

class MainView: UIView {
    
    // MARK: - GUI components
    
    /// ツールバーを配置するコンテナ
    let toolbarContainer = UIView()
    
    /// ステッカーボード、カメラビューを配置するコンテナ
    let canvasContainer = UIView()
    
    /// 撮影ボタン
    let captureButton = UIButton(type: .custom)
    
    /// ズーム倍率ボタン
    let zoomFactorButton = UIButton(type: .custom)
    
    /// 透明度変更スライダ
    let opacitySlider = UISlider()
    
    /// キャンバス上端からセーフエリアへの制約
    private var canvasTopConstraintToSafeArea = NSLayoutConstraint()
    
    /// キャンバス上端からトップバー下端への制約
    private var canvasTopConstraintToTopbar = NSLayoutConstraint()
    
    /// キャンバスのアスペクト比の制約
    private var canvasAspectRatioConstraint = NSLayoutConstraint()
    
    // MARK: - Properties
    
    weak var delegate: MainViewDelegate?
    
    /// デバイスがノッチを持つかどうか
    private var hasNotch: Bool { safeAreaInsets.bottom > 0 }
    
    // MARK: - Initializing

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Components setup
    
    private func setup(){
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .black
        
        setupContainers()
        setupCaptureButton()
        setupZoomFactorButton()
        setupOpacitySlider()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onDeviceOrientationChange), name: DeviceOrientation.orientationDidChangeNotification, object: nil)
    }
    
    private func setupContainers(){
        // キャンバスコンテナ
        canvasContainer.backgroundColor = .clear
        addSubview(canvasContainer)
        canvasContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            canvasContainer.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
            canvasContainer.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor)
        ])
        
        // ツールバーコンテナ
        toolbarContainer.backgroundColor = .clear
        addSubview(toolbarContainer)
        toolbarContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toolbarContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            toolbarContainer.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor),
            toolbarContainer.rightAnchor.constraint(equalTo: safeAreaLayoutGuide.rightAnchor),
            toolbarContainer.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // キャンバス上端の制約
        canvasTopConstraintToSafeArea = canvasContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor)
        canvasTopConstraintToTopbar = canvasContainer.topAnchor.constraint(equalTo: toolbarContainer.bottomAnchor)
        NSLayoutConstraint.activate([canvasTopConstraintToSafeArea, canvasTopConstraintToTopbar])
        updateCanvasTopConstraints()
    }
    
    private func setupCaptureButton(){
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        
        let captureButtonImage = UIImage(systemName: "circle.inset.filled")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        captureButton.setImage(captureButtonImage, for: .normal)

        let captureButtonImageView = captureButton.imageView!
        captureButtonImageView.translatesAutoresizingMaskIntoConstraints = false
        captureButtonImageView.contentMode = .scaleAspectFit
        
        let buttonImageMargin: CGFloat = 5
        NSLayoutConstraint.activate([
            captureButton.widthAnchor.constraint(equalTo: captureButton.heightAnchor),
            captureButtonImageView.topAnchor.constraint(equalTo: captureButton.topAnchor, constant: buttonImageMargin),
            captureButtonImageView.bottomAnchor.constraint(equalTo: captureButton.bottomAnchor, constant: -buttonImageMargin),
            captureButtonImageView.leftAnchor.constraint(equalTo: captureButton.leftAnchor, constant: buttonImageMargin),
            captureButtonImageView.rightAnchor.constraint(equalTo: captureButton.rightAnchor, constant: -buttonImageMargin),
        ])
        
        // メインビューに追加
        addSubview(captureButton)
        NSLayoutConstraint.activate([
            captureButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            captureButton.heightAnchor.constraint(equalTo: captureButton.widthAnchor),
            captureButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        captureButton.addTarget(self, action: #selector(onTapCaptureButton), for: .touchUpInside)
    }
    
    private func setupZoomFactorButton(){
        zoomFactorButton.translatesAutoresizingMaskIntoConstraints = false
        
        let buttonHeight: CGFloat = 36
        zoomFactorButton.setTitle("1.0x", for: .normal)
        zoomFactorButton.layer.cornerRadius = buttonHeight / 2.0
        zoomFactorButton.layer.borderColor = UIColor.white.cgColor
        zoomFactorButton.layer.borderWidth = 1.5
        zoomFactorButton.backgroundColor = .gray.withAlphaComponent(0.5)
        
        // メインビューに追加
        addSubview(zoomFactorButton)
        NSLayoutConstraint.activate([
            zoomFactorButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            zoomFactorButton.leftAnchor.constraint(equalTo: captureButton.rightAnchor, constant: 15),
            zoomFactorButton.centerYAnchor.constraint(equalTo: captureButton.centerYAnchor),
            zoomFactorButton.heightAnchor.constraint(equalToConstant: buttonHeight)
        ])
        
        zoomFactorButton.addTarget(self, action: #selector(onTapZoomFactorButton), for: .touchUpInside)
    }
    
    private func setupOpacitySlider(){
        opacitySlider.translatesAutoresizingMaskIntoConstraints = false
        
        opacitySlider.minimumValue = 0.2
        opacitySlider.maximumValue = 0.8
        let trackTintColor = UIColor.white.withAlphaComponent(0.5)
        opacitySlider.minimumTrackTintColor = trackTintColor
        opacitySlider.maximumTrackTintColor = trackTintColor
        let minImage = UIImage(systemName: "circle.dashed")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        let maxImage = UIImage(systemName: "circle.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        opacitySlider.minimumValueImage = minImage
        opacitySlider.maximumValueImage = maxImage
        
        // メインビューに追加
        addSubview(opacitySlider)
        NSLayoutConstraint.activate([
            opacitySlider.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            opacitySlider.centerXAnchor.constraint(equalTo: centerXAnchor),
            opacitySlider.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -15)
        ])
        opacitySlider.addTarget(self, action: #selector(onChangeOpacitySlider), for: .valueChanged)
    }
    
    private func updateCanvasTopConstraints(){
        canvasTopConstraintToSafeArea.priority = hasNotch ? .defaultLow : .defaultHigh
        canvasTopConstraintToTopbar.priority = hasNotch ? .defaultHigh : .defaultLow
    }
    
    // MARK: - GUI Events
    
    @objc private func onTapCaptureButton(){
        delegate?.mainViewDidTapCaptureButton(self)
    }
    
    @objc private func onTapZoomFactorButton(){
        delegate?.mainViewDidTapZoomFactorButton(self)
    }
    
    @objc private func onChangeOpacitySlider(){
        delegate?.mainView(self, didChangeOpacitySliderValue: opacitySlider.value)
    }
    
    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        
        // キャンバス上端の制約を更新
        updateCanvasTopConstraints()
        
        // ツールバーコンテナの背景色を再設定
        toolbarContainer.backgroundColor = hasNotch ? .black : .clear
    }
    
    @objc private func onDeviceOrientationChange(){
        let angle = DeviceOrientation.shared.currentOrientation.rotationAngle
        UIView.animate(withDuration: 0.2) {[weak self] in
            self?.zoomFactorButton.transform = .init(rotationAngle: angle)
        }
    }

}
