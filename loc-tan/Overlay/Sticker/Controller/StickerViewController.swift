//
//  StickerViewController.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/07/20.
//

import UIKit

class StickerViewController: UIViewController {
    
    let stickerModel: StickerModel
    
    private lazy var interaction = UIEditMenuInteraction(delegate: self)
    
    weak var delegate: StickerViewControllerDelegate?
    
    private var stickerView: StickerView {view as! StickerView}
    
    // MARK: - Gesture history
    
    private var panGestureTranslation: CGPoint = .zero
    
    private var pinchGestureScale: CGFloat = 1.0
    
    private var rotationGestureAngle: CGFloat = 0.0
    
    // MARK: - Initializing
    
    init(stickerModel: StickerModel){
        self.stickerModel = stickerModel
        super.init(nibName: nil, bundle: nil)
        self.stickerModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        // NOTE: このクラス自体をNSCoder経由でインスタンス化することはないだろうという読み
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View lifecycle
    
    override func loadView() {
        self.view = StickerView(
            frame: .zero,
            image: stickerModel.image,
            center: stickerModel.center,
            width: stickerModel.width,
            angle: stickerModel.angle,
            opacity: stickerModel.opacity)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapSticker))
        self.view.addGestureRecognizer(tapGesture)
        
        self.view.addInteraction(interaction)
    }
    
    // MARK: - State modification
    
    func updateHighlightedState(_ isHighlighted: Bool) async {
        await stickerView.setGrayedOut(isHighlighted)
    }
    
    func updateVisibility(_ isVisible: Bool) async{
        await stickerView.updateVisibility(isVisible)
    }
    
    // MARK: - Gestures
    
    @objc private func onTapSticker(_ gesture: UITapGestureRecognizer){
        // モデルの情報をデバッグ表示
        print(String(format: "Sticker at:%@ size:%.2f angle:%.2f state:%@", stickerModel.center.shortDescription, stickerModel.width, stickerModel.angle.degrees, stickerModel.isTargetted ? "active" : "inactive"))
        
        // 活性化されていないなら要求する
        if !stickerModel.isTargetted {
            delegate?.stickerViewDidRequireActivation(self)
            return
        }
        
        // 編集メニューを表示する
        showMenu(at: gesture.location(in: view))
    }
    
    func onPanSticker(_ gesture: UIPanGestureRecognizer){
        switch gesture.state {
        case .began:
            panGestureTranslation = .zero
            fallthrough
            
        case .changed:
            let translation = gesture.translation(in: view.superview)
            panGestureTranslation += translation
            view.center += translation
            break
            
        case .ended:
            stickerModel.center += panGestureTranslation
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

extension StickerViewController: StickerModelDelegate {
    
    func stickerModel(_ model: StickerModel, didMove center: CGPoint) {
        print("pan: moved to \(center.shortDescription)")
        stickerView.updateCenter(center)
    }
    
    func stickerModel(_ model: StickerModel, didChange width: CGFloat) {
        print(String(format: "pinch: scaled to %.2f px width", width))
        stickerView.updateWidth(width)
    }
    
    func stickerModel(_ model: StickerModel, didChange angle: Angle) {
        print(String(format: "rot: rotated to %.2f deg", angle.degrees))
        stickerView.updateAngle(angle)
    }
    
    func stickerModel(_ model: StickerModel, didChange isTargetted: Bool) {
        Task {
            await stickerView.setGrayedOut(!model.isTargetted && model.shouldIndicateState)
        }
    }
    
    func stickerModel(_ model: StickerModel, didChange opacity: Float, animated: Bool) {
        guard animated else {
            stickerView.updateOpacity(opacity)
            return
        }
        
        Task {
            await stickerView.updateOpacity(opacity)
        }
    }
    
    func stickerModel(_ model: StickerModel, didChangeIndication shouldIndicateState: Bool) {
        Task {
            await stickerView.setGrayedOut(!model.isTargetted && model.shouldIndicateState)
        }
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
