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
    
    /// キャンバス上端からセーフエリアへの制約
    @IBOutlet private weak var canvasTopConstraintToSafeArea: NSLayoutConstraint!
    
    /// キャンバス上端からトップバー下端への制約
    @IBOutlet private weak var canvasTopConstraintToTopbar: NSLayoutConstraint!
    
    /// デバイスがノッチを持つかどうか
    private var hasNotch: Bool {
        return view.safeAreaInsets.bottom > 0
    }
    
    private let boardModel = StickerBoardModel(stickers: [])
    
    private var boardController: StickerBoardViewController!
    
    private let boardModelSaveKey = "StickerBoard"
    
    /// ステッカーボードを配置するコンテナ
    @IBOutlet private weak var containerView: UIView! {
        didSet {
            boardController = .init(boardModel: boardModel)
            
            // StickerBoardViewControllerを子ViewControllerとして追加
            addChild(boardController)
            containerView.addSubview(boardController.view)
            NSLayoutConstraint.activate([
                containerView.topAnchor.constraint(equalTo: boardController.view.topAnchor),
                containerView.bottomAnchor.constraint(equalTo: boardController.view.bottomAnchor),
                containerView.leftAnchor.constraint(equalTo: boardController.view.leftAnchor),
                containerView.rightAnchor.constraint(equalTo: boardController.view.rightAnchor),
            ])
            boardController.didMove(toParent: self)
        }
    }
    
    private let imageIdentifiers = [
        "dive_stage",
        "rainbow_bridge_night",
        "rainbow_bridge_noon",
        "tokyo_skytree"
    ]
    
    // MARK: - View lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func updateViewConstraints() {
        // ノッチがあるならキャンバスをトップビューまで、なければセーフエリアまで広げる
        canvasTopConstraintToSafeArea.priority = hasNotch ? .defaultLow : .defaultHigh
        canvasTopConstraintToTopbar.priority = hasNotch ? .defaultHigh : .defaultLow
        
        super.updateViewConstraints()
    }

    
    
    @IBAction func onTapAdd(_ sender: Any) {
        // ピッカーを表示
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
    
    private func spawnSticker(with image: UIImage){
        // スポーン位置は画面中央 幅は画面より少し狭く
        let width = boardController.view.bounds.width * 0.9
        let center = CGPoint.zero
        let sticker = StickerModel(image: image, center: center, width: width, angle: .zero)
        boardModel.add(sticker)
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
