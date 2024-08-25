//
//  CameraViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/08/04.
//

import UIKit
import AVKit

class CameraViewController: UIViewController {
    
    let model: CameraModel
    
    /// ズーム倍率文字列
    var zoomFactorDescription: String { .init(format: "%.1fx", (currentInputDevice?.videoZoomFactor ?? 1.0) / zoomFactorUnit) }
    
    var delegate: CameraViewControllerDelegate?
    
    // MARK: - Private
    
    /// キャプチャセッション
    private let session = AVCaptureSession()
    
    /// 写真出力
    private let photoOutput = AVCapturePhotoOutput()
    
    /// 現在の入力デバイス
    private var currentInputDevice: AVCaptureDevice? { (session.inputs.first as? AVCaptureDeviceInput)?.device }
    
    /// 現在の入力デバイスが持つズーム倍率の単位
    ///
    /// ズーム倍率 (`AVCaptureDevice.videoZoomFactor`) 自体は常に `1.0` 以上の値を取るため、
    /// 超広角レンズ (いわゆる`0.5x`) を持つ機種では**この値と実際のズーム倍率が一致しない。**
    ///
    /// そこで、デバイスがレンズを切り替える閾値リスト (`virtualDeviceSwitchOverVideoZoomFactors`) の最小値、
    /// すなわち**超広角レンズから広角レンズ(すべてのiPhoneが共通してもつレンズ)に切り替わる閾値となる`videoZoomFactor`**を取得し、その値でズーム倍率を除する。
    ///
    /// たとえば `0.5x` のレンズを持つiPhone 11の場合、このリストは `[2, 6]` となるため、`videoZoomFactor` が `1.0` の際は `1.0 / 2 = 0.5` となり、
    /// 純正カメラアプリと同じ倍率表示が実現できる。
    private var zoomFactorUnit: CGFloat { .init(currentInputDevice?.virtualDeviceSwitchOverVideoZoomFactors.first?.floatValue ?? 1.0) }
    
    /// ズーム開始時の倍率
    private var initialZoomFactor: CGFloat = 0.0
    
    private let ciContext = CIContext()
    
    private var cameraView: CameraView { view as! CameraView }
    
    private var zoomRampingObserver: NSKeyValueObservation?
    
    // MARK: - Initializing
    
    init(cameraModel: CameraModel) {
        self.model = cameraModel
        super.init(nibName: nil, bundle: nil)
        self.model.delegate = self
    }
    
    required init?(coder: NSCoder) {
        // NOTE: このクラス自体をNSCoder経由でインスタンス化することはないだろうという読み
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycles
    
    override func loadView() {
        self.view = CameraView(frame: .zero, aspectRatio: model.aspectRatio)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ジェスチャを構成
        [UITapGestureRecognizer(target: self, action: #selector(onTap)),
         UIPinchGestureRecognizer(target: self, action: #selector(onPinch))].forEach(cameraView.addGestureRecognizer)
        
        // セッションを構成
        configureCaptureSession(session)
        cameraView.session = session
        
        // 広角レンズ(すべてのiPhoneが共通してもつレンズ)を使用するよう、ズーム倍率を設定しておく
        updateDeviceZoomFactor(to: zoomFactorUnit)
    }

    /// キャプチャセッションを構成
    private func configureCaptureSession(_ session: AVCaptureSession){
        session.beginConfiguration()
        
        // セッションプリセットを設定
        session.sessionPreset = .hd4K3840x2160
        
        // デフォルトのキャプチャデバイスを取得
        guard let device = queryMostSuitableCamera(),
              let deviceInput = try? AVCaptureDeviceInput(device: device) else {
            session.commitConfiguration()
            return
        }
        
        // 入出力の構成
        if(session.canAddInput(deviceInput)){
            session.addInput(deviceInput)
        }
        if session.canAddOutput(photoOutput){
            session.addOutput(photoOutput)
        }
        
        session.commitConfiguration()
    }
    
    /// デバイスの持つ最適なカメラデバイスを返す
    private func queryMostSuitableCamera() -> AVCaptureDevice? {
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInTripleCamera,
            .builtInDualWideCamera,
            .builtInDualCamera,
            .builtInWideAngleCamera
        ]
        return deviceTypes.compactMap({AVCaptureDevice.default($0, for: .video, position: .back)}).first
    }
    
    // MARK: - Gestures
    
    @objc private func onTap(_ gesture: UITapGestureRecognizer){
        // タップ位置をレイヤ座標系に変換し、デバイスのフォーカス位置を移動
        let viewTapPoint = gesture.location(in: cameraView)
        let layerTapPoint = cameraView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: viewTapPoint)
        updateFocusPoint(to: layerTapPoint)
        
        // プレビューViewのフォーカス位置を再設定
        cameraView.focusPoint = viewTapPoint
    }
    
    @objc private func onPinch(_ gesture: UIPinchGestureRecognizer){
        guard let device = currentInputDevice else {return}
        
        // ズーム開始時のスケールを保持しておく
        if gesture.state == .began {
            initialZoomFactor = device.videoZoomFactor
        }
        
        setZoomFactor(initialZoomFactor * gesture.scale)
    }
    
    // MARK: - Methods
    
    func startSession() {
        guard !self.session.isRunning else {return}
        
        DispatchQueue.global().async {[weak self] in
            self?.session.startRunning()
        }
        
        zoomRampingObserver = currentInputDevice?.observe(\.isRampingVideoZoom, changeHandler: { [weak self] _, _ in
            guard let `self` = self,
                  let currentZoomFactor = currentInputDevice?.videoZoomFactor else {return}
            self.delegate?.cameraView(self, didChangeZoomFactor: currentZoomFactor)
        })
    }
    
    func stopSession() {
        zoomRampingObserver?.invalidate()
        
        DispatchQueue.global().async {[weak self] in
            self?.session.stopRunning()
        }
    }
    
    func capturePhoto(with settings: AVCapturePhotoSettings? = nil) {
        self.photoOutput.capturePhoto(with: settings ?? .init(), delegate: self)
    }
    
    /// デバイスのズーム倍率を変更する
    /// - Parameters:
    ///   - scale: 設定する倍率
    ///   - rate: 倍率変更速度
    /// - Note: rateに値を設定すると、その速度でズームします。
    func setZoomFactor(_ scale: CGFloat, rate: Float? = nil) {
        guard let device = currentInputDevice else {return}
        
        // ジェスチャのスケールからデバイスに渡すスケールを計算し、受理可能な値にクリップする
        // なお最大スケールに関してはやたらデカい値が許容されるので、アプリ側で最大値を設けておく
        let minScale = device.minAvailableVideoZoomFactor
        let maxScale = min(device.maxAvailableVideoZoomFactor, 20.0)
        let newScale = min(max(scale, minScale), maxScale)
        
        // デバイスに設定を反映
        updateDeviceZoomFactor(to: newScale, rate: rate)
        delegate?.cameraView(self, didChangeZoomFactor: newScale)
    }
    
    /// ズーム倍率を切り替える
    func snapZoomFactor() {
        // 最小倍率を含むズーム閾値の配列
        let thresholdZoomFactors: [CGFloat] = ([1.0] +  (currentInputDevice?.virtualDeviceSwitchOverVideoZoomFactors.map({.init($0.floatValue)}) ?? [])).sorted()
        
        // 現在の倍率を下回る最大の倍率を取得
        let currentZoomFactor = currentInputDevice?.videoZoomFactor ?? 1.0
        let candidates = thresholdZoomFactors.filter({$0 < currentZoomFactor})
        guard let nextZoomFactor = candidates.last ?? thresholdZoomFactors.last else {return}
        
        // デバイスに設定を反映
        setZoomFactor(nextZoomFactor, rate: 50.0)
    }
    
    private func updateFocusPoint(to point: CGPoint) {
        guard let device = currentInputDevice else {return}
        do {
            try device.lockForConfiguration()
            if device.isFocusPointOfInterestSupported {
                device.focusPointOfInterest = point
                device.focusMode = .autoFocus
            }
            if device.isExposurePointOfInterestSupported {
                device.exposurePointOfInterest = point
                device.exposureMode = .autoExpose
            }
            device.unlockForConfiguration()
        } catch {
            print("Failed to focus: \(error)")
        }
    }
    
    private func updateDeviceZoomFactor(to scale: CGFloat, rate: Float? = nil) {
        guard let device = currentInputDevice else {return}
        do {
            try device.lockForConfiguration()
            
            if let rate = rate {
                device.ramp(toVideoZoomFactor: scale, withRate: rate)
            } else {
                device.videoZoomFactor = scale
            }
            device.unlockForConfiguration()
        } catch {
            print("Failed to zoom: \(error)")
        }
    }
    
    /// デバイスの向きから生成する画像の向きを取得
    /// - Parameter deviceOrientation: デバイスの向き
    /// - Returns: 画像の向き
    private func imageOrientation(_ deviceOrientation: UIDeviceOrientation = DeviceOrientation.shared.currentOrientation) -> UIImage.Orientation {
        switch deviceOrientation {
        case .portrait:
            return .right
        case .portraitUpsideDown:
            return .left
        case .landscapeLeft:
            return .up
        case .landscapeRight:
            return .down
        default:
            return .right
        }
    }
}

extension CameraViewController: CameraModelDelegate {
    
    func cameraModel(_ model: CameraModel, didChangeAspectRatio aspectRatio: AspectRatio) {
        cameraView.aspectRatio = aspectRatio
    }
    
}

extension CameraViewController: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        guard error == nil,
              let cgImage = photo.cgImageRepresentation() else {
            delegate?.cameraView(self, didFailCapture: error)
            return
        }
        let ciImage = CIImage(cgImage: cgImage)
        let imageSize = ciImage.extent.size
        let cropSize = imageSize.maxFitSize(at: model.aspectRatio)
        let cropOrigin = CGPoint(x: (imageSize.width - cropSize.width) / 2.0, y: (imageSize.height - cropSize.height) / 2.0)
        print("Raw size: \(imageSize) -> \(cropSize)@\(cropOrigin)")
        let croppedCIImage = ciImage.cropped(to: .init(origin: cropOrigin, size: cropSize))
        guard let croppedCGImage = ciContext.createCGImage(croppedCIImage, from: croppedCIImage.extent) else {
            delegate?.cameraView(self, didFailCapture: nil)
            return
        }
        let croppedImage = UIImage(cgImage: croppedCGImage, scale: 1.0, orientation: imageOrientation())
        delegate?.cameraView(self, didCapture: croppedImage)
    }
    
}
