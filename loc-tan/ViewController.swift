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
            toolbarContainer.backgroundColor = .clear
            toolbarViewController = .init(nibName: nil, bundle: nil)
            toolbarViewController.delegate = self
            toolbarViewController.model = toolbarModel
            
            addChild(toolbarViewController)
            let toolbarView = toolbarViewController.view!
            toolbarContainer.addSubview(toolbarView)
            NSLayoutConstraint.activate([
                toolbarView.topAnchor.constraint(equalTo: toolbarContainer.topAnchor, constant: 5),
                toolbarView.bottomAnchor.constraint(equalTo: toolbarContainer.bottomAnchor, constant: -5),
                toolbarView.leftAnchor.constraint(equalTo: toolbarContainer.leftAnchor, constant: 5),
                toolbarView.rightAnchor.constraint(equalTo: toolbarContainer.rightAnchor, constant: -5),
            ])
            toolbarViewController.didMove(toParent: self)
        }
    }
    
    /// ステッカーボード、カメラビューを配置するコンテナ
    @IBOutlet private weak var canvasContainer: UIView! {
        didSet {
            canvasContainer.backgroundColor = .clear
            cameraViewController = .init(nibName: nil, bundle: nil)
            cameraViewController.delegate = self
            
            addChild(cameraViewController)
            let cameraView = cameraViewController.view!
            canvasContainer.addSubview(cameraView)
            NSLayoutConstraint.activate([
                cameraView.topAnchor.constraint(equalTo: canvasContainer.topAnchor),
                cameraView.bottomAnchor.constraint(equalTo: canvasContainer.bottomAnchor),
                cameraView.leftAnchor.constraint(equalTo: canvasContainer.leftAnchor),
                cameraView.rightAnchor.constraint(equalTo: canvasContainer.rightAnchor),
            ])
            cameraViewController.didMove(toParent: self)
            
            stickerBoardViewController = .init(boardModel: stickerBoardModel)
            
            addChild(stickerBoardViewController)
            let stickerBoardView = stickerBoardViewController.view!
            canvasContainer.addSubview(stickerBoardView)
            NSLayoutConstraint.activate([
                stickerBoardView.topAnchor.constraint(equalTo: canvasContainer.topAnchor),
                stickerBoardView.bottomAnchor.constraint(equalTo: canvasContainer.bottomAnchor),
                stickerBoardView.leftAnchor.constraint(equalTo: canvasContainer.leftAnchor),
                stickerBoardView.rightAnchor.constraint(equalTo: canvasContainer.rightAnchor),
            ])
            stickerBoardViewController.didMove(toParent: self)
        }
    }
    
    // MARK: - ViewControllers
    
    private var cameraViewController: CameraViewController!
    
    private var stickerBoardViewController: StickerBoardViewController!
    
    private var toolbarViewController: ToolbarViewController!
    
    private var photoPickerViewController: PHPickerViewController!
    
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
        
        // フォトピッカーを準備しておく
        configurePhotoPicker()
        
        view.backgroundColor = .black
        
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
    
    // MARK: - Methods
    
    private func configurePhotoPicker(){
        let config = {
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.filter = .images
            config.selectionLimit = 1
            config.preferredAssetRepresentationMode = .current
            return config
        }()
        photoPickerViewController = .init(configuration: config)
        photoPickerViewController.delegate = self
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
    
    /// 画像ピッカーを表示する
    private func presentPhotoPicker(){
        self.present(photoPickerViewController, animated: true)
    }
    
    /// 与えられた画像のステッカーを追加する
    /// - Parameter image: ステッカーの画像
    /// - Note: ステッカーはビュー中心に生成されます。
    private func spawnSticker(with image: UIImage){
        let width = stickerBoardViewController.view.bounds.width
        let sticker = StickerModel(image: image, center: .zero, width: width, angle: .zero)
        stickerBoardModel.add(sticker)
    }
    
    private func expandStickerToFullScreen(){
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
            // TODO: カメラ設定の実装
            print("settings")
        case .Rotate:
            rotateSticker()
        case .Fullsize:
            expandStickerToFullScreen()
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
        // TODO: ズーム倍率コントローラの実装
        print("zoom: \(scale)")
    }
    
    func cameraView(_ viewController: CameraViewController, didCapture image: UIImage) {
        saveImageToPhotoLibrary(image)
    }
    
    func cameraView(_ viewController: CameraViewController, didFailCapture error: (any Error)?) {
        // TODO: 撮影エラー時の処理
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
