//
//  ToolBarView.swift
//  loc-tan
//
//  Created by EnchantCode on 2024/06/23.
//

import UIKit

/// 画面上端に表示されるツールバー
class ToolBarView: UIView {
    
    // MARK: - Properties
    
    /// 現在のモード
    private var currentMode: ToolBarMode = .normal
    
    /// デリゲート
    weak var delegate: ToolBarViewDelegate?
    
    /// データソース
    weak var dataSource: ToolBarViewDataSource?
    
    /// モード別ツールバーアイテムリスト
    private var itemTypes: [ToolBarMode: [ToolBarItemType]] = [:]
    
    // MARK: - GUI Components
    
    /// サブアイテムを配置するスタック
    private let itemStack: ToolBarItemStack = .init(items: [])
    
    /// モードスイッチャ
    private let modeSwitcher: ToolBarModeSwitcher = .init(mode: .normal)
    
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    /// ビューのセットアップ
    private func setup(){
        // サブアイテムスタックを構成
        self.addSubview(itemStack)
        NSLayoutConstraint.activate([
            itemStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            itemStack.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),
            itemStack.heightAnchor.constraint(equalTo: heightAnchor),
            itemStack.rightAnchor.constraint(equalTo: rightAnchor)
        ])
        itemStack.delegate = self
        
        // モードスイッチャを構成
        self.addSubview(modeSwitcher)
        NSLayoutConstraint.activate([
            modeSwitcher.centerYAnchor.constraint(equalTo: centerYAnchor),
            modeSwitcher.heightAnchor.constraint(equalTo: heightAnchor),
            modeSwitcher.leftAnchor.constraint(equalTo: leftAnchor)
        ])
        modeSwitcher.addTarget(self, action: #selector(onTapModeSwitcher), for: .touchUpInside)
    }
    
    // MARK: - Gesture recognizers
    
    @objc private func onTapModeSwitcher(_ sender: ToolBarModeSwitcher) {
        currentMode = currentMode == .normal ? .edit : .normal
        let animationDuration = 0.2
        
        Task{
            self.delegate?.modeWillSwitch(self, to: currentMode)
            await withTaskGroup(of: Void.self) {[weak self] group in
                guard let `self` = self else {return}
                group.addTask { await sender.switchMode(to: self.currentMode, duration: animationDuration) }
                group.addTask { await self.itemStack.setButtons(self.getItemTypes(for: self.currentMode), duration: animationDuration) }
            }
            self.delegate?.modeDidSwitch(self, to: currentMode)
        }
        
    }
    
    // MARK: - Methods
    
    /// ツールバーのアイテムを再読み込み
    func reloadItemStack(){
        let animationDuration = 0.2
        Task {
            await self.itemStack.setButtons(self.getItemTypes(for: self.currentMode), duration: animationDuration)
        }
    }
    
    /// モードに対応するアイテムをルックアップする
    /// - Parameter mode: モード
    /// - Returns: モードに対応するアイテムタイプのリスト
    /// - Note: 存在しない場合はデータソースに尋ね、応答をキャッシュします。
    private func getItemTypes(for mode: ToolBarMode) -> [ToolBarItemType]{
        // 存在するならそれを返す
        if let exisingTypes = itemTypes[mode] {
            return exisingTypes
        }
        
        // しないならデリゲートに聞く
        if let typesFromDelegate = dataSource?.toolbar(self, buttonTypesFor: currentMode) {
            itemTypes[mode] = typesFromDelegate
            return typesFromDelegate
        }
        
        // しらん！
        return []
    }
    
}

extension ToolBarView: ToolBarItemStackDelegate {
    
    func toolbarItemStack(_ itemStack: ToolBarItemStack, didTapItem type: ToolBarItemType) {
        delegate?.toolbar(self, didTapItem: type)
    }
    
}
