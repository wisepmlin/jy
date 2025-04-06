//
//  LinkViewController.swift
//  MarkupEditor
//
//  Created by Steven Harris on 9/1/22.
//

import UIKit

// 链接编辑视图控制器
class LinkViewController: UIViewController {

    // 选中状态
    private var selectionState: SelectionState = MarkupEditor.selectionState
    // 初始链接地址
    private var initialHref: String?
    // 当前链接地址
    private var href: String!
    // 处理过的链接地址(去除空格)
    private var argHRef: String? { href.isEmpty ? nil : href.trimmingCharacters(in: .whitespacesAndNewlines) }
    // 原始链接地址
    private var originalHRef: String?
    // 标题标签
    private var label: UILabel!
    // 链接输入框
    private var linkView: UITextView!
    // 链接输入框占位标签
    private var linkViewLabel: UILabel!
    // 按钮容器
    private var buttonStack: UIStackView!
    // 删除按钮
    private var removeButton: UIButton!
    // 删除按钮宽度约束
    private var removeButtonWidthConstraint: NSLayoutConstraint!
    // 间隔视图
    private var spacer: UIView!
    // 间隔视图宽度约束
    private var spacerWidthConstraint: NSLayoutConstraint!
    // 取消按钮
    private var cancelButton: UIButton!
    // 取消按钮宽度约束
    private var cancelButtonWidthConstraint: NSLayoutConstraint!
    // 保存按钮
    private var saveButton: UIButton!
    // 保存按钮宽度约束
    private var saveButtonWidthConstraint: NSLayoutConstraint!
    
    // 初始化方法
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initializeContents()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // 初始化视图内容
    private func initializeContents() {
        view.backgroundColor = UIColor.systemBackground
        originalHRef = MarkupEditor.selectionState.href
        href = originalHRef ?? ""
        initializeLabel()
        initializeLinkView()
        initializeButtons()
        initializeLayout()
    }
    
    // 初始化标题标签
    private func initializeLabel() {
        label = UILabel()
        label.text = MarkupEditor.selectionState.href == nil ? "Add a link:" : "Modify the link:"
        label.autoresizingMask = [.flexibleWidth]
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
    }
    
    // 初始化链接输入框
    private func initializeLinkView() {
        linkView = UITextView(frame: CGRect.zero)
        linkView.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        linkView.text = originalHRef
        linkView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        linkView.translatesAutoresizingMaskIntoConstraints = false
        linkView.keyboardType = .URL
        linkView.autocapitalizationType = .none
        linkView.autocorrectionType = .no
        linkView.delegate = self
        
        // 设置占位标签
        linkViewLabel = UILabel()
        linkViewLabel.text = "Enter link URL"
        linkViewLabel.font = .italicSystemFont(ofSize: (linkView.font?.pointSize)!)
        linkViewLabel.sizeToFit()
        linkView.addSubview(linkViewLabel)
        linkViewLabel.frame.origin = CGPoint(x: 5, y: (linkView.font?.pointSize)! / 2)
        linkViewLabel.textColor = .tertiaryLabel
        linkViewLabel.isHidden = !linkView.text.isEmpty
        
        // 设置输入框边框
        linkView.layer.borderWidth = 2
        linkView.layer.borderColor = view.tintColor.cgColor
        view.addSubview(linkView)
    }
    
    // 初始化按钮
    private func initializeButtons() {
        // 初始化按钮容器
        buttonStack = UIStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.spacing = 4
        buttonStack.distribution = .fill
        view.addSubview(buttonStack)
        
        // 初始化删除按钮
        removeButton = UIButton(configuration: .borderedTinted(), primaryAction: nil)
        removeButton.preferredBehavioralStyle = UIBehavioralStyle.pad
        removeButton.configuration?.baseBackgroundColor = view.backgroundColor
        removeButton.configuration?.title = "Remove Link"
        removeButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        removeButton.layer.cornerRadius = 5
        removeButton.layer.borderWidth = 0.8
        removeButton.autoresizingMask = [.flexibleWidth]
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        removeButtonWidthConstraint = removeButton.widthAnchor.constraint(equalToConstant: 110)
        removeButtonWidthConstraint.priority = .required
        removeButton.addTarget(self, action: #selector(remove), for: .touchUpInside)
        buttonStack.addArrangedSubview(removeButton)
        
        // 初始化间隔视图
        spacer = UIView()
        spacer.autoresizingMask = [.flexibleWidth]
        spacerWidthConstraint = spacer.widthAnchor.constraint(equalToConstant: 0)
        spacerWidthConstraint.priority = .defaultLow
        buttonStack.addArrangedSubview(spacer)
        
        // 初始化取消按钮
        cancelButton = UIButton(configuration: .borderedProminent(), primaryAction: nil)
        cancelButton.preferredBehavioralStyle = UIBehavioralStyle.pad
        cancelButton.configuration?.title = "Cancel"
        cancelButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        cancelButton.autoresizingMask = [.flexibleWidth]
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButtonWidthConstraint = cancelButton.widthAnchor.constraint(equalToConstant: 70)
        cancelButtonWidthConstraint.priority = .defaultHigh
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.borderWidth = 0.8
        cancelButton.layer.borderColor = view.tintColor.cgColor
        buttonStack.addArrangedSubview(cancelButton)
        
        // 初始化保存按钮
        saveButton = UIButton(configuration: .borderedProminent(), primaryAction: nil)
        saveButton.preferredBehavioralStyle = UIBehavioralStyle.pad
        saveButton.configuration?.title = "OK"
        saveButton.autoresizingMask = [.flexibleWidth]
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButtonWidthConstraint = saveButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor, multiplier: 1)
        saveButtonWidthConstraint.priority = .defaultHigh
        saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        buttonStack.addArrangedSubview(saveButton)
        saveButton.configurationUpdateHandler = setSaveCancel(_:)
        setButtons()
    }
    
    // 初始化布局约束
    private func initializeLayout() {
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            buttonStack.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            buttonStack.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
            buttonStack.heightAnchor.constraint(equalToConstant: MarkupEditor.toolbarStyle.buttonHeight()),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            spacerWidthConstraint,
            removeButtonWidthConstraint,
            removeButton.heightAnchor.constraint(equalToConstant: MarkupEditor.toolbarStyle.buttonHeight()),
            cancelButtonWidthConstraint,
            cancelButton.heightAnchor.constraint(equalToConstant: MarkupEditor.toolbarStyle.buttonHeight()),
            saveButtonWidthConstraint,
            saveButton.heightAnchor.constraint(equalToConstant: MarkupEditor.toolbarStyle.buttonHeight()),
            linkView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            linkView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
            linkView.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            linkView.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -8),
        ])
    }
    
    // 视图显示后的处理
    override func viewDidAppear(_ animated: Bool) {
        setButtons()
        linkView.becomeFirstResponder()
    }
    
    // 设置保存和取消按钮的外观
    private func setSaveCancel(_ button: UIButton) {
        if saveButton.isEnabled {
            saveButton.configuration?.baseBackgroundColor = view.tintColor
            saveButton.configuration?.baseForegroundColor = view.backgroundColor
            cancelButton.configuration?.baseBackgroundColor = view.backgroundColor
            cancelButton.configuration?.baseForegroundColor = view.tintColor
        } else {
            saveButton.configuration?.baseBackgroundColor = view.backgroundColor
            saveButton.configuration?.baseForegroundColor = view.tintColor
            cancelButton.configuration?.baseBackgroundColor = view.tintColor
            cancelButton.configuration?.baseForegroundColor = view.backgroundColor
        }
    }
    
    // 设置按钮状态
    private func setButtons() {
        removeButton.isEnabled = MarkupEditor.selectionState.isInLink
        if removeButton.isEnabled {
            removeButton.layer.borderColor = view.tintColor.cgColor
        } else {
            removeButton.layer.borderColor = UIColor.clear.cgColor
        }
        saveButton.isEnabled = canSave()
    }
    
    // 判断是否可以保存
    private func canSave() -> Bool {
        if originalHRef == nil {
            guard MarkupEditor.selectionState.canLink, let href = argHRef else { return false }
            return href.isValidURL
        } else {
            if let href = argHRef {
                return href.isValidURL
            } else {
                return false
            }
        }
    }

    // 关闭视图
    private func dismiss() {
        dismiss(animated: true) {
            MarkupEditor.selectedWebView?.becomeFirstResponder()
        }
    }
    
    // 删除链接
    @objc private func remove() {
        MarkupEditor.selectedWebView?.insertLink(nil)
        dismiss()
    }
    
    // 保存链接
    @objc private func save() {
        MarkupEditor.selectedWebView?.insertLink(argHRef)
        dismiss()
    }
    
    // 取消操作
    @objc private func cancel() {
        MarkupEditor.selectedWebView?.endModalInput {
            self.dismiss()
        }
    }
    
    // 处理菜单项的可用状态
    @objc override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        switch action {
        case #selector(showPluggableLinkPopover):
            return true
        default:
            return super.canPerformAction(action, withSender: sender)
        }
    }
    
    // 显示/隐藏弹出窗口
    @objc func showPluggableLinkPopover() {
        dismiss()
    }
    
}

// MARK: - UITextViewDelegate
extension LinkViewController: UITextViewDelegate {
    
    // 文本变化时的处理
    func textViewDidChange(_ textView: UITextView) {
        href = textView.text
        linkViewLabel.isHidden = !textView.text.isEmpty
        setButtons()
    }
    
    // 处理文本输入
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if canSave() {
                save()
            } else {
                cancel()
            }
            return false
        } else if text == "\t" {
            return false
        }
        return true
    }
    
}
