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
                toolbarView.topAnchor.constraint(equalTo: toolbarContainer.topAnchor),
                toolbarView.bottomAnchor.constraint(equalTo: toolbarContainer.bottomAnchor),
                toolbarView.leftAnchor.constraint(equalTo: toolbarContainer.leftAnchor),
                toolbarView.rightAnchor.constraint(equalTo: toolbarContainer.rightAnchor),
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
            
            updateCanvasInteractionState()
        }
    }
    
    /// オブジェクト透明度スライダ
    @IBOutlet weak var opacitySlider: UISlider! {
        didSet {
            opacitySlider.value = stickerBoardModel.stickersOpacity
        }
    }
    
    /// ズーム倍率ボタン
    @IBOutlet weak var zoomFactorButton: UIButton! {
        didSet {
            zoomFactorButton.setTitle(cameraViewController.zoomFactorDescription, for: .normal)
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
    
    /// ステッカーの状態を表示すべきかどうか
    private var shouldIndicateState: Bool { toolbarModel.currentMode == .Edit }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func onChangeOpacitySlider(_ sender: Any) {
        stickerBoardModel.setStickersOpacity(opacitySlider.value, animated: false)
    }
    
    @IBAction func onTapZoom(_ sender: Any) {
        // TODO: ズーム倍率ボタンタップ時の挙動を実装
    }
    
    // MARK: - Methods
    
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
        let config = {
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.filter = .images
            config.selectionLimit = 1
            config.preferredAssetRepresentationMode = .current
            return config
        }()
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        if let sheet = picker.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersGrabberVisible = true
        }
        self.present(picker, animated: true)
    }
    
    /// 与えられた画像のステッカーを追加する
    /// - Parameter image: ステッカーの画像
    /// - Note: ステッカーはビュー中心に生成されます。
    private func spawnSticker(with image: UIImage){
        let width = stickerBoardViewController.view.bounds.width
        let sticker = StickerModel(
            image: image,
            center: .zero,
            width: width,
            angle: .zero,
            isTargetted: false,
            opacity: stickerBoardModel.stickersOpacity,
            shouldIndicateState: stickerBoardModel.shouldIndicateState)
        stickerBoardModel.add(sticker)
    }
    
    /// キャンバスビュー内のインタラクション状態を更新する
    private func updateCanvasInteractionState(){
        // 編集モードのときはステッカーボード、撮影モードの時はカメラビューのユーザ操作を受け付ける
        let isEditMode = toolbarModel.currentMode == .Edit
        stickerBoardViewController.view.isUserInteractionEnabled = isEditMode
        cameraViewController.view.isUserInteractionEnabled = !isEditMode
    }
}

extension ViewController: ToolbarViewDelegate {
    
    func toolbarView(_ view: ToolbarView, didTapItem item: ToolBarItem) {
        switch item {
        case .Settings:
            // TODO: カメラ設定の実装
            print("settings")
        case .Rotate:
            stickerBoardViewController.rotateCurrentSticker(diff: .init(degrees: 90))
        case .Fullsize:
            stickerBoardViewController.expandCurrentStickerToFullScreen()
        case .Add:
            presentPhotoPicker()
        }
    }
    
    func toolbarViewDidTapModeSwitcher(_ view: ToolbarView) {
        let nextMode = toolbarModel.currentMode.opposite
        toolbarModel.setMode(nextMode)
        
        // 編集モードのときはステッカーのハイライトを有効にする
        stickerBoardModel.shouldIndicateState = nextMode == .Edit
        updateCanvasInteractionState()
    }
    
}

extension ViewController: CameraViewControllerDelegate {
    
    func cameraView(_ viewController: CameraViewController, didChangeZoomFactor scale: CGFloat) {
        zoomFactorButton.setTitle(cameraViewController.zoomFactorDescription, for: .normal)
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
