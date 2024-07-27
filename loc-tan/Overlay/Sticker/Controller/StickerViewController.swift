//
//  StickerViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/20.
//

import UIKit

class StickerViewController: UIViewController {
    
    let stickerModel: StickerModel
    
    private var isActive: Bool = false
    
    private lazy var interaction = UIEditMenuInteraction(delegate: self)
    
    weak var delegate: StickerViewControllerDelegate?
    
    // MARK: - Gesture history
    
    private var panGestureTranslation: CGPoint = .zero
    
    private var pinchGestureScale: CGFloat = 1.0
    
    private var rotationGestureAngle: CGFloat = 0.0
    
    // MARK: - Initializing
    
    init(stickerModel: StickerModel){
        self.stickerModel = stickerModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        guard let model = coder.decodeObject(forKey: "model") as? StickerModel else {return nil}
        self.stickerModel = model
        super.init(coder: coder)
    }
    
    override func encode(with coder: NSCoder) {
        super.encode(with: coder)
        coder.encode(stickerModel, forKey: "model")
    }
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        coder.encode(stickerModel, forKey: "model")
    }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        // TODO: フォールバック画像を持たせるべきか、それとも?
        let sticker = StickerView(frame: .zero, image: stickerModel.image!)
        sticker.setWidth(stickerModel.width)
        sticker.setCenter(stickerModel.center)
        sticker.setAngle(stickerModel.angle)
        
        self.view = sticker
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapSticker))
        self.view.addGestureRecognizer(tapGesture)
        
        self.view.addInteraction(interaction)
    }
    
    // MARK: - State modification
    
    func activate() async {
        await (self.view as! StickerView).setStatusRing(true)
        isActive = true
    }
    
    func deactivate() async {
        await (self.view as! StickerView).setStatusRing(false)
        isActive = false
    }
    
    // MARK: - Gestures
    
    @objc private func onTapSticker(_ gesture: UITapGestureRecognizer){
        // モデルの情報をデバッグ表示
        print(String(format: "Sticker at:%@ size:%.2f angle:%.2f", stickerModel.center.shortDescription, stickerModel.width, stickerModel.angle.degrees))
        
        // 活性化されていないなら要求する
        if !isActive {
            delegate?.stickerViewDidRequireActivation(self)
            return
        }
        
        // 編集メニューを表示する
        showMenu(at: gesture.location(in: view))
    }
    
    func onPanSticker(_ gesture: UIPanGestureRecognizer){
        switch gesture.state {
        case .began:
            print("pan: began (current:\(view.center.shortDescription))")
            panGestureTranslation = .zero
            fallthrough
            
        case .changed:
            let translation = gesture.translation(in: view.superview)
            panGestureTranslation += translation
            view.center += translation
            break
            
        case .ended:
            stickerModel.center += panGestureTranslation
            print("pan: end (diff:\(panGestureTranslation.shortDescription) view-center:\(view.center.shortDescription) model-center:\(stickerModel.center.shortDescription)")
            (view as! StickerView).setCenter(stickerModel.center)
            panGestureTranslation = .zero
            break
            
        case .cancelled:
            view.center -= panGestureTranslation
            panGestureTranslation = .zero
            break
        
        default:
            break
        }
        gesture.setTranslation(.zero, in: view)
    }
    
    func onPinchSticker(_ gesture: UIPinchGestureRecognizer){
        switch gesture.state {
        case .began:
            print("scale: began")
            pinchGestureScale = 1.0
            fallthrough
            
        case .changed:
            let scaleDiff = gesture.scale
            pinchGestureScale *= scaleDiff
            view.transform = view.transform.scaledBy(x: scaleDiff, y: scaleDiff)
            break
            
        case .ended:
            print(String(format: "scale: end (diff: %.2f current: %@", pinchGestureScale, view.center.shortDescription))
            view.transform = view.transform.scaledBy(x: 1.0 / pinchGestureScale, y: 1.0 / pinchGestureScale)
            stickerModel.width *= pinchGestureScale
            (view as! StickerView).setWidth(stickerModel.width)
            pinchGestureScale = 1.0
            break
            
        case .cancelled:
            view.center -= panGestureTranslation
            pinchGestureScale = 1.0
            break
        
        default:
            break
        }
        gesture.scale = 1.0
    }
    
    func onRotateSticker(_ gesture: UIRotationGestureRecognizer){
        switch gesture.state {
        case .began:
            print("rot: began")
            rotationGestureAngle = 0.0
            fallthrough
            
        case .changed:
            let rotDiff = gesture.rotation
            rotationGestureAngle += rotDiff
            view.transform = view.transform.rotated(by: rotDiff)
            break
            
        case .ended:
            stickerModel.angle += rotationGestureAngle
            print(String(format: "rot: end (diff: %.2f, new: %.2f)", rotationGestureAngle / (2 * .pi) * 360.0, stickerModel.angle.degrees))
            rotationGestureAngle = 0.0
            break
            
        case .cancelled:
            view.transform = view.transform.rotated(by: -rotationGestureAngle)
            rotationGestureAngle = 0.0
            break
            
        default:
            break
        }
        gesture.rotation = 0.0
    }
    
    // MARK: - Edit menu
    
    @MainActor
    private func showMenu(at point: CGPoint){
        guard self.view.becomeFirstResponder() else {return}
        interaction.presentEditMenu(with: .init(identifier: nil, sourcePoint: point))
    }

}

extension StickerViewController: UIEditMenuInteractionDelegate {
    
    func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {
        return .init(children: [
            UIAction(title: "削除", attributes: .destructive, handler: { _ in
                self.delegate?.stickerViewDidRequireDeletion(self)
            })
        ])
    }
    
}
