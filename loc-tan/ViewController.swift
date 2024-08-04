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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await self.cameraViewController.startSession()
        }
    }
    
    
    @IBAction func onTapCapture(_ sender: Any) {
        cameraViewController.capturePhoto()
    }
    
}

extension ViewController: CameraViewControllerDelegate {
    
    func cameraView(_ viewController: CameraViewController, didChangeZoomFactor scale: CGFloat) {
        print("zoom: \(scale)")
    }
    
    func cameraView(_ viewController: CameraViewController, didCapture image: UIImage) {
        print(image.size)
    }
    
    func cameraView(_ viewController: CameraViewController, didFailCapture error: (any Error)?) {
        print(error)
    }
    
}
