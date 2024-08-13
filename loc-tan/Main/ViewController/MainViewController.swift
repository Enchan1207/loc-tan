//
//  MainViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/08/12.
//

import UIKit
import PhotosUI

class MainViewController: UIViewController {
    
    // MARK: - ViewControllers
    
    private var cameraViewController: CameraViewController!
    
    private var stickerBoardViewController: StickerBoardViewController!
    
    private var toolbarViewController: ToolbarViewController!
    
    // MARK: - Properties
    
    private let stickerBoardModel = StickerBoardModel(stickers: [])
    
    private let toolbarModel = ToolbarModel(mode: .camera)
    
    /// ステータスバーを隠す
    override var prefersStatusBarHidden: Bool {true}
    
    /// 現在のアスペクト比
    private var currentAspectRatio: AspectRatio = .wide {
        didSet {
            mainView.updateCanvasAspectRatio(currentAspectRatio)
        }
    }
    
    /// ステッカーの状態を表示すべきかどうか
    private var shouldIndicateState: Bool { toolbarModel.currentMode == .edit }
    
    private var mainView: MainView { self.view as! MainView }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        self.view = MainView()
        mainView.delegate = self
        
        // ツールバー
        toolbarViewController = .init()
        toolbarViewController.delegate = self
        toolbarViewController.model = toolbarModel
        placeChildController(toolbarViewController, to: mainView.toolbarContainer)
        
        // カメラビュー
        cameraViewController = .init()
        cameraViewController.delegate = self
        placeChildController(cameraViewController, to: mainView.canvasContainer)
        
        // ステッカーボード
        stickerBoardViewController = .init(boardModel: stickerBoardModel)
        placeChildController(stickerBoardViewController, to: mainView.canvasContainer)
        
        // その他コントロール
        mainView.opacitySlider.value = stickerBoardModel.stickersOpacity
        mainView.zoomFactorButton.setTitle(cameraViewController.zoomFactorDescription, for: .normal)
        
        updateCanvasInteractionState()
    }

    /// 子VCをコンテナビューいっぱいに配置する
    /// - Parameters:
    ///   - controller: 子VC
    ///   - container: 配置先
    private func placeChildController(_ controller: UIViewController, to container: UIView){
        guard let childView = controller.view else {return}
        addChild(controller)
        container.addSubview(childView)
        NSLayoutConstraint.activate([
            childView.topAnchor.constraint(equalTo: container.topAnchor),
            childView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            childView.leftAnchor.constraint(equalTo: container.leftAnchor),
            childView.rightAnchor.constraint(equalTo: container.rightAnchor),
        ])
        controller.didMove(toParent: self)
    }
    
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
        let isEditMode = toolbarModel.currentMode == .edit
        stickerBoardViewController.view.isUserInteractionEnabled = isEditMode
        cameraViewController.view.isUserInteractionEnabled = !isEditMode
    }

}

extension MainViewController: MainViewDelegate {
    
    func mainViewDidTapCaptureButton(_ view: MainView) {
        cameraViewController.capturePhoto()
    }
    
    func mainViewDidTapZoomFactorButton(_ view: MainView) {
        cameraViewController.snapZoomFactor()
    }
    
    func mainView(_ view: MainView, didChangeOpacitySliderValue to: Float) {
        stickerBoardModel.setStickersOpacity(to, animated: false)
    }
    
}

extension MainViewController: ToolbarViewDelegate {
    
    func toolbarView(_ view: ToolbarView, didTapItem item: ToolBarItem) {
        switch item {
        case .aspectRatio:
            currentAspectRatio = currentAspectRatio.next
        case .rotate:
            stickerBoardViewController.rotateCurrentSticker(diff: .init(degrees: 90))
        case .expandToFullScreen:
            stickerBoardViewController.expandCurrentStickerToFullScreen()
        case .add:
            presentPhotoPicker()
        }
    }
    
    func toolbarViewDidTapModeSwitcher(_ view: ToolbarView) {
        let nextMode = toolbarModel.currentMode.opposite
        toolbarModel.setMode(nextMode)
        
        // 編集モードのときはステッカーのハイライトを有効にする
        stickerBoardModel.shouldIndicateState = nextMode == .edit
        updateCanvasInteractionState()
    }
    
}

extension MainViewController: CameraViewControllerDelegate {
    
    func cameraView(_ viewController: CameraViewController, didChangeZoomFactor scale: CGFloat) {
        mainView.zoomFactorButton.setTitle(cameraViewController.zoomFactorDescription, for: .normal)
    }
    
    func cameraView(_ viewController: CameraViewController, didCapture image: UIImage) {
        saveImageToPhotoLibrary(image)
    }
    
    func cameraView(_ viewController: CameraViewController, didFailCapture error: (any Error)?) {
        // TODO: 撮影エラー時の処理
    }
    
}

extension MainViewController: PHPickerViewControllerDelegate {
    
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

fileprivate extension AspectRatio {
    
    var next: AspectRatio {
        switch self {
        case .standard:
            .wide
        case .wide:
            .standard
        default:
            .wide
        }
    }
    
}
