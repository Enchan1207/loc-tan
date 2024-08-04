//
//  CameraViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/08/04.
//

import UIKit
import AVKit

class CameraViewController: UIViewController {
    
    /// 現在のズーム倍率
    private(set) var currentZoomFactor: CGFloat = 1.0
    
    // MARK: - Private
    
    /// キャプチャセッション
    private let session = AVCaptureSession()
    
    /// 写真出力
    private let photoOutput = AVCapturePhotoOutput()
    
    /// 現在の入力デバイス
    private var currentInputDevice: AVCaptureDevice? { (session.inputs.first as? AVCaptureDeviceInput)?.device }
    
    /// ズーム開始時の倍率
    private var initialZoomFactor: CGFloat = 1.0
    
    private var cameraView: CameraView { view as! CameraView }
    
    // MARK: - View lifecycles
    
    override func loadView() {
        self.view = CameraView(frame: .zero)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ジェスチャを構成
        [UITapGestureRecognizer(target: self, action: #selector(onTap)),
         UIPinchGestureRecognizer(target: self, action: #selector(onPinch))].forEach(cameraView.addGestureRecognizer)
        
        // セッションを構成
        configureCaptureSession(session)
        cameraView.session = session
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // セッション開始
        DispatchQueue.global().async{[weak self] in
            self?.session.startRunning()
        }
    }
    
    /// キャプチャセッションを構成
    private func configureCaptureSession(_ session: AVCaptureSession){
        session.beginConfiguration()
        
        // セッションプリセットを設定
        session.sessionPreset = .hd4K3840x2160
        
        // デフォルトのキャプチャデバイスを取得
        guard let device = AVCaptureDevice.default(for: .video),
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
    
    // MARK: - Gestures
    
    @objc private func onTap(_ gesture: UITapGestureRecognizer){
        // タップ位置をレイヤ座標系に変換し、デバイスのフォーカス位置を移動
        let viewTapPoint = gesture.location(in: cameraView)
        let layerTapPoint = cameraView.videoPreviewLayer.captureDevicePointConverted(fromLayerPoint: viewTapPoint)
        updateDeviceFocusPoint(to: layerTapPoint)
        
        // プレビューViewのフォーカス位置を再設定
        cameraView.focusPoint = viewTapPoint
    }
    
    @objc private func onPinch(_ gesture: UIPinchGestureRecognizer){
        guard let device = currentInputDevice else {return}
        
        // ズーム開始時のスケールを保持しておく
        if gesture.state == .began {
            initialZoomFactor = device.videoZoomFactor
        }
        
        // ジェスチャのスケールからデバイスに渡すスケールを計算し、受理可能な値にクリップする
        // なお最大スケールに関してはやたらデカい値が許容されるので、アプリ側で最大値を設けておく
        let minScale = device.minAvailableVideoZoomFactor
        let maxScale = min(device.maxAvailableVideoZoomFactor, 20.0)
        let newScale = min(max(initialZoomFactor * gesture.scale, minScale), maxScale)
        currentZoomFactor = newScale
        
        // デバイスに設定を反映
        updateDeviceZoomFactor(to: newScale)
        
        // TODO: Notify to parent
    }
    
    // MARK: - Methods
    
    // TODO: async?
    private func updateDeviceFocusPoint(to point: CGPoint){
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
    
    // TODO: async?
    private func updateDeviceZoomFactor(to scale: CGFloat){
        guard let device = currentInputDevice else {return}
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = scale
            device.unlockForConfiguration()
        } catch {
            print("Failed to zoom: \(error)")
        }
    }
    
}
