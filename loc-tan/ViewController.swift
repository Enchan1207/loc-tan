//
//  ViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/15.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {
    
    /// ステータスバーを隠す
    override var prefersStatusBarHidden: Bool {true}
    
    private var cameraViewController: CameraViewController!
    
    /// ステッカーボードを配置するコンテナ
    @IBOutlet private weak var containerView: UIView! {
        didSet {
            cameraViewController = .init(nibName: nil, bundle: nil)
            cameraViewController.delegate = self
            
            // CameraViewControllerを子ViewControllerとして追加
            addChild(cameraViewController)
            containerView.addSubview(cameraViewController.view)
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: cameraViewController.view.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: cameraViewController.view.bottomAnchor),
                containerView.leftAnchor.constraint(equalTo: cameraViewController.view.leftAnchor),
                containerView.rightAnchor.constraint(equalTo: cameraViewController.view.rightAnchor),
            ])
            cameraViewController.didMove(toParent: self)
        }
    }
    
    // MARK: - View lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cameraViewController.startSession()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Notifications
    
    @objc private func appDidEnterBackground(){
        self.cameraViewController.stopSession()
    }
    
    @objc private func appDidBecomeActive(){
        self.cameraViewController.startSession()
    }
    
    // MARK: - GUI event
    
    
    @IBAction func onTapCapture(_ sender: Any) {
        cameraViewController.capturePhoto()
    }
    
    /// フォトライブラリに写真を保存する
    /// - Parameter image: 保存する画像
    private func saveImageToPhotoLibrary(_ image: UIImage){
        // TODO: クロージャじゃなくてｴｲｼﾝｸとか使う?
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized else {
                print("Photo library access denied")
                return
            }
            
            // 写真を保存
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }) { success, error in
                if(success){
                    print("Photo saved")
                }else {
                    print("error: \(error!)")
                }
            }
        }
    }
    
}

extension ViewController: CameraViewControllerDelegate {
    
    func cameraView(_ viewController: CameraViewController, didChangeZoomFactor scale: CGFloat) {
        print("zoom: \(scale)")
    }
    
    func cameraView(_ viewController: CameraViewController, didCapture image: UIImage) {
        saveImageToPhotoLibrary(image)
    }
    
    func cameraView(_ viewController: CameraViewController, didFailCapture error: (any Error)?) {
        print(error)
    }
    
}
