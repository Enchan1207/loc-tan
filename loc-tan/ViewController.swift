//
//  ViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/15.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {
    
    // MARK: - GUI Components
    
    /// キャンバス上端からセーフエリアへの制約
    @IBOutlet private weak var canvasTopConstraintToSafeArea: NSLayoutConstraint!
    
    /// キャンバス上端からトップバー下端への制約
    @IBOutlet weak var canvasTopConstraintToTopbar: NSLayoutConstraint!
    
    /// ツールバーを配置するコンテナ
    @IBOutlet private weak var toolbarContainer: UIView! {
        didSet {
            toolbarViewController = .init(nibName: nil, bundle: nil)
            toolbarViewController.delegate = self
            toolbarViewController.model = toolbarModel
            
            addChild(toolbarViewController)
            toolbarContainer.addSubview(toolbarViewController.view)
            NSLayoutConstraint.activate([
                toolbarContainer.topAnchor.constraint(equalTo: toolbarViewController.view.topAnchor),
                toolbarContainer.bottomAnchor.constraint(equalTo: toolbarViewController.view.bottomAnchor),
                toolbarContainer.leftAnchor.constraint(equalTo: toolbarViewController.view.leftAnchor),
                toolbarContainer.rightAnchor.constraint(equalTo: toolbarViewController.view.rightAnchor),
            ])
            toolbarViewController.didMove(toParent: self)
        }
    }
    
    /// ステッカーボード、カメラビューを配置するコンテナ
    @IBOutlet private weak var canvasContainer: UIView! {
        didSet {
            cameraViewController = .init(nibName: nil, bundle: nil)
            cameraViewController.delegate = self
            
            addChild(cameraViewController)
            canvasContainer.addSubview(cameraViewController.view)
            NSLayoutConstraint.activate([
                canvasContainer.topAnchor.constraint(equalTo: cameraViewController.view.topAnchor),
                canvasContainer.bottomAnchor.constraint(equalTo: cameraViewController.view.bottomAnchor),
                canvasContainer.leftAnchor.constraint(equalTo: cameraViewController.view.leftAnchor),
                canvasContainer.rightAnchor.constraint(equalTo: cameraViewController.view.rightAnchor),
            ])
            cameraViewController.didMove(toParent: self)
            
            stickerBoardViewController = .init(boardModel: stickerBoardModel)
            
            addChild(stickerBoardViewController)
            canvasContainer.addSubview(stickerBoardViewController.view)
            NSLayoutConstraint.activate([
                canvasContainer.topAnchor.constraint(equalTo: stickerBoardViewController.view.topAnchor),
                canvasContainer.bottomAnchor.constraint(equalTo: stickerBoardViewController.view.bottomAnchor),
                canvasContainer.leftAnchor.constraint(equalTo: stickerBoardViewController.view.leftAnchor),
                canvasContainer.rightAnchor.constraint(equalTo: stickerBoardViewController.view.rightAnchor),
            ])
            stickerBoardViewController.didMove(toParent: self)
        }
    }
    
    // MARK: - ViewControllers
    
    private var cameraViewController: CameraViewController!
    
    private var stickerBoardViewController: StickerBoardViewController!
    
    private var toolbarViewController: ToolbarViewController!
    
    // MARK: - Properties
    
    private let stickerBoardModel = StickerBoardModel(stickers: [])
    
    private let toolbarModel = ToolbarModel(mode: .Camera)
    
    /// ステータスバーを隠す
    override var prefersStatusBarHidden: Bool {true}
    
    /// デバイスがノッチを持つかどうか
    private var hasNotch: Bool { view.safeAreaInsets.bottom > 0 }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        toolbarContainer.backgroundColor = hasNotch ? .black : .clear
        self.cameraViewController.startSession()
    }
    
    override func updateViewConstraints() {
        // ノッチがあるならキャンバスをトップビューまで、なければセーフエリアまで広げる
        canvasTopConstraintToSafeArea.priority = hasNotch ? .defaultLow : .defaultHigh
        canvasTopConstraintToTopbar.priority = hasNotch ? .defaultHigh : .defaultLow
        
        super.updateViewConstraints()
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
    
    /// 画像ピッカーを構成して表示する
    private func presentPhotoPicker(){
        let config = {
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.filter = .images
            config.selectionLimit = 1
            config.preferredAssetRepresentationMode = .current
            return config
        }()
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        self.present(picker, animated: true)
    }
    
    /// 与えられた画像のステッカーを追加する
    /// - Parameter image: ステッカーの画像
    /// - Note: ステッカーはビュー中心に生成されます。
    private func spawnSticker(with image: UIImage){
        let width = stickerBoardViewController.view.bounds.width
        let sticker = StickerModel(image: image, center: .zero, width: width, angle: .zero)
        stickerBoardModel.add(sticker)
    }
    
    private func extendSticker(){
        // 選択中のステッカーモデルを取得
        guard let activeStickerModel = stickerBoardViewController.activeStickerController?.stickerModel else {return}
        
        // ステッカーの角度をスナップする
        let newAngle: Angle = ({ angle in
            if angle.degrees > 0 {
                if angle.degrees > 135 {
                    return .init(degrees: 180)
                }
                if angle.degrees > 45 {
                    return .init(degrees: 90)
                }
            } else {
                if angle.degrees < -135 {
                    return .init(degrees: -180)
                }
                if angle.degrees < -45 {
                    return .init(degrees: -90)
                }
            }
            return .zero
        })(activeStickerModel.angle)
        activeStickerModel.angle = newAngle
        
        // 中心に移動
        // TODO: センターに戻すボタンが欲しいかも?
        activeStickerModel.center = .zero
        
        // 回転角度を考慮したステッカーのアスペクト比を計算し、
        let isRotated = abs(newAngle.degrees) > 5
        let stickerImageSize = activeStickerModel.image.size
        let stickerAspectRatioOnScreen = isRotated ? stickerImageSize.height / stickerImageSize.width : stickerImageSize.width / stickerImageSize.height
        
        // ビューをはみ出ない最大サイズを取得
        let maxStickerSizeOnScreen: CGSize = ({viewSize, aspectRatio in
            // 幅基準
            let sizeForWidth = CGSize(width: viewSize.width, height: viewSize.width / aspectRatio)            
            // 高さ基準
            let sizeForHeight = CGSize(width: viewSize.height * aspectRatio, height: viewSize.height)
            return sizeForWidth.height <= viewSize.height ? sizeForWidth : sizeForHeight
        })(stickerBoardViewController.view.bounds, stickerAspectRatioOnScreen)
        
        // 設定
        activeStickerModel.width = isRotated ? maxStickerSizeOnScreen.height : maxStickerSizeOnScreen.width
    }
    
    private func rotateSticker(){
        // 選択中のステッカーモデルを取得
        guard let activeStickerModel = stickerBoardViewController.activeStickerController?.stickerModel else {return}
        
        // 角度を取得
        let stickerAngle = activeStickerModel.angle
        
        // FIXME: ここなんかおかしい
        // 次に回す角度を計算・割り当て
        let newAngle: Angle = ({ angle in
            if angle.degrees > 0 {
                if angle.degrees > 135 {
                    return .init(degrees: -90)
                }
                if angle.degrees > 45 {
                    return .init(degrees: 180)
                }
                return .init(degrees: 90)
            } else {
                if angle.degrees < -135 {
                    return .init(degrees: 90)
                }
                if angle.degrees < -45 {
                    return .init(degrees: -180)
                }
                return .init(degrees: -90)
            }
        })(stickerAngle)
        activeStickerModel.angle = newAngle
    }
    
}

extension ViewController: ToolbarViewDelegate {
    
    func toolbarView(_ view: ToolbarView, didTapItem item: ToolBarItem) {
        switch item {
        case .Settings:
            print("settings")
        case .Rotate:
            rotateSticker()
        case .Fullsize:
            extendSticker()
        case .Add:
            presentPhotoPicker()
        }
    }
    
    func toolbarViewDidTapModeSwitcher(_ view: ToolbarView) {
        let nextMode = toolbarModel.currentMode.opposite
        toolbarModel.setMode(nextMode)
        
        // 編集モードのときはステッカーボード、撮影モードの時はカメラビューのユーザ操作を受け付ける
        let isSwitchToEdit = nextMode == .Edit
        stickerBoardViewController.view.isUserInteractionEnabled = isSwitchToEdit
        cameraViewController.view.isUserInteractionEnabled = !isSwitchToEdit
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
    }
    
}

extension ViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else {return}
        
        provider.loadObject(ofClass: UIImage.self) {[weak self] item, error in
            guard error == nil, let image = item as? UIImage else {
                print(error!)
                return
            }
            DispatchQueue.main.async {
                self?.spawnSticker(with: image)
            }
        }
    }
    
}
