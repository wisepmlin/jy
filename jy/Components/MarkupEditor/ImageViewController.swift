//
//  ImageViewController.swift
//  MarkupEditor
//
//  Created by Steven Harris on 9/2/22.
//

import UIKit

/// 图片编辑视图控制器
/// 用于处理图片的插入、修改和删除操作
/// 提供图片URL和描述文本的编辑界面
class ImageViewController: UIViewController {

    private var selectionState: SelectionState = MarkupEditor.selectionState
    private var initialHref: String?
    private var src: String!
    private var argSrc: String? { argForEntry(src) }
    private var alt: String!
    private var argAlt: String? { argForEntry(alt) }
    private var originalSrc: String?
    private var originalAlt: String?
    private var savedSrc: String?
    private var savedAlt: String?
    private var label: UILabel!
    private var textStack: UIStackView!
    private var srcView: UITextView!
    private var srcViewLabel: UILabel!
    private var altView: UITextView!
    private var altViewLabel: UILabel!
    private var buttonStack: UIStackView!
    private var selectButton: UIButton!
    private var selectButtonWidthConstraint: NSLayoutConstraint!
    private var cancelButton: UIButton!
    private var cancelButtonWidthConstraint: NSLayoutConstraint!
    private var saveButtonWidthConstraint: NSLayoutConstraint!
    private var saveButton: UIButton!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initializeContents()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// 初始化视图控制器的内容
    /// 设置背景色并初始化所有UI组件
    private func initializeContents() {
        view.backgroundColor = UIColor.systemBackground
        originalSrc = MarkupEditor.selectionState.src
        src = originalSrc ?? ""
        savedSrc = originalSrc
        originalAlt = MarkupEditor.selectionState.alt
        alt = originalAlt ?? ""
        savedAlt = originalAlt
        initializeLabel()
        initializeTextViews()
        initializeButtons()
        initializeLayout()
    }
    
    /// 初始化顶部标签
    /// 显示"插入图片"或"修改图片"的提示文本
    private func initializeLabel() {
        label = UILabel()
        label.text = originalSrc == nil ? "Insert an image:" : "Modify the image:"
        label.autoresizingMask = [.flexibleWidth]
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
    }
    
    /// 初始化文本输入视图
    /// 包括图片URL输入框和描述文本输入框
    private func initializeTextViews() {
        textStack = UIStackView()
        textStack.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        textStack.translatesAutoresizingMaskIntoConstraints = false
        textStack.axis = .vertical
        textStack.spacing = 4
        textStack.distribution = .fill
        view.addSubview(textStack)
        srcView = UITextView(frame: CGRect.zero)
        srcView.layer.borderWidth = 2
        srcView.layer.borderColor = UIColor.lightGray.cgColor
        srcView.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        srcView.text = originalSrc
        srcView.keyboardType = .URL
        srcView.autocapitalizationType = .none
        srcView.autocorrectionType = .no
        srcView.delegate = self
        srcViewLabel = UILabel()
        srcViewLabel.text = "Enter image URL"
        srcViewLabel.font = .italicSystemFont(ofSize: (srcView.font?.pointSize)!)
        srcViewLabel.sizeToFit()
        srcView.addSubview(srcViewLabel)
        srcViewLabel.frame.origin = CGPoint(x: 5, y: (srcView.font?.pointSize)! / 2)
        srcViewLabel.textColor = .tertiaryLabel
        srcViewLabel.isHidden = !srcView.text.isEmpty
        textStack.addArrangedSubview(srcView)
        altView = UITextView(frame: CGRect.zero)
        altView.layer.borderWidth = 2
        altView.layer.borderColor = UIColor.lightGray.cgColor
        altView.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        altView.text = originalAlt
        altView.keyboardType = .default
        altView.delegate = self
        altViewLabel = UILabel()
        altViewLabel.text = "Enter description"
        altViewLabel.font = .italicSystemFont(ofSize: (altView.font?.pointSize)!)
        altViewLabel.sizeToFit()
        altView.addSubview(altViewLabel)
        altViewLabel.frame.origin = CGPoint(x: 5, y: (altView.font?.pointSize)! / 2)
        altViewLabel.textColor = .tertiaryLabel
        altViewLabel.isHidden = !srcView.text.isEmpty
        textStack.addArrangedSubview(altView)
    }
    
    /// 初始化底部按钮
    /// 包括选择图片、取消和保存按钮
    private func initializeButtons() {
        buttonStack = UIStackView()
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.spacing = 4
        buttonStack.distribution = .fill
        view.addSubview(buttonStack)
        if MarkupEditor.allowLocalImages {
            selectButton = UIButton(configuration: .borderedTinted(), primaryAction: nil)
            selectButton.preferredBehavioralStyle = UIBehavioralStyle.pad
            selectButton.configuration?.baseBackgroundColor = view.backgroundColor
            selectButton.configuration?.title = "Select..."
            // Avoid word wrapping
            selectButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            selectButton.layer.cornerRadius = 5
            selectButton.layer.borderWidth = 0.8
            selectButton.autoresizingMask = [.flexibleWidth]
            selectButton.translatesAutoresizingMaskIntoConstraints = false
            selectButtonWidthConstraint = selectButton.widthAnchor.constraint(equalToConstant: 110)
            selectButtonWidthConstraint.priority = .required
            selectButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
            buttonStack.addArrangedSubview(selectButton)
        }
        cancelButton = UIButton(configuration: .borderedProminent(), primaryAction: nil)
        cancelButton.preferredBehavioralStyle = UIBehavioralStyle.pad
        cancelButton.configuration?.title = "Cancel"
        // Avoid word wrapping
        cancelButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        cancelButton.autoresizingMask = [.flexibleWidth]
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButtonWidthConstraint = cancelButton.widthAnchor.constraint(equalToConstant: 70)
        cancelButtonWidthConstraint.priority = .defaultHigh
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        buttonStack.addArrangedSubview(cancelButton)
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
        // The cancelButton is always enabled, so it has an outline color.
        // It's background changes to indicate whether it's the default action,
        // which is something we change depending on whether we canSave().
        // It's hard to believe I have to do this in the year 2022, but I guess
        // so goes it when you actually want to be able to see a button rather than
        // just random text on the screen that might or might not be a button.
        cancelButton.layer.cornerRadius = 5
        cancelButton.layer.borderWidth = 0.8
        cancelButton.layer.borderColor = view.tintColor.cgColor
    }
    
    /// 设置视图布局约束
    private func initializeLayout() {
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            label.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            buttonStack.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            buttonStack.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
            buttonStack.heightAnchor.constraint(equalToConstant: MarkupEditor.toolbarStyle.buttonHeight()),
            buttonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            cancelButtonWidthConstraint,
            cancelButton.heightAnchor.constraint(equalToConstant: MarkupEditor.toolbarStyle.buttonHeight()),
            saveButtonWidthConstraint,
            saveButton.heightAnchor.constraint(equalToConstant: MarkupEditor.toolbarStyle.buttonHeight()),
            textStack.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 8),
            textStack.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -8),
            textStack.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 8),
            textStack.bottomAnchor.constraint(equalTo: buttonStack.topAnchor, constant: -8),
            altView.heightAnchor.constraint(equalTo: srcView.heightAnchor, multiplier: 1, constant: 0),
        ])
        if MarkupEditor.allowLocalImages {
            NSLayoutConstraint.activate([
                selectButtonWidthConstraint,
                selectButton.heightAnchor.constraint(equalToConstant: MarkupEditor.toolbarStyle.buttonHeight()),
            ])
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setButtons()
        setTextViews()
        srcView.becomeFirstResponder()
    }
    
    /// 设置保存按钮和取消按钮的外观
    ///
    /// 取消按钮始终处于启用状态，但当保存按钮禁用时会显示为主题色填充，
    /// 表示按下回车键时的默认操作是取消。当保存按钮启用时，
    /// 保存按钮显示为主题色，而取消按钮显示为边框且背景色为普通背景色，
    /// 表示按下回车键时的默认操作是保存。
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
    
    /// 根据srcView内容的变化设置按钮的外观状态
    ///
    /// 注意：设置保存按钮的启用/禁用状态会触发其configurationUpdateHandler，
    /// 进而执行setSaveCancel来配置保存按钮和取消按钮
    private func setButtons() {
        if let selectButton = selectButton {
            selectButton.isEnabled = MarkupEditor.selectionState.canInsert
            if selectButton.isEnabled {
                selectButton.layer.borderColor = view.tintColor.cgColor
            } else {
                selectButton.layer.borderColor = UIColor.clear.cgColor
            }
        }
        saveButton.isEnabled = canSave()
    }
    
    private func setTextViews() {
        if srcView.isFirstResponder {
            srcView.layer.borderColor = view.tintColor.cgColor
            altView.layer.borderColor = UIColor.lightGray.cgColor
        } else if altView.isFirstResponder {
            srcView.layer.borderColor = UIColor.lightGray.cgColor
            altView.layer.borderColor = view.tintColor.cgColor
        } else {
            srcView.layer.borderColor = UIColor.lightGray.cgColor
            altView.layer.borderColor = UIColor.lightGray.cgColor
        }
    }

    private func argForEntry(_ entry: String) -> String? {
        let arg = entry.trimmingCharacters(in: .whitespacesAndNewlines)
        return arg.isEmpty ? nil : arg
    }
    
    /// 保存图片，如果argSrc为nil，则需要使用modifyImage来删除图片
    private func saveImage(_ handler: (()->Void)? = nil) {
        if let argSrc = argSrc {
            MarkupEditor.selectedWebView?.insertImage(src: argSrc, alt: argAlt, handler: handler)
        } else {
            MarkupEditor.selectedWebView?.modifyImage(src: argSrc, alt: argAlt, handler: handler)
        }
        savedSrc = src
        savedAlt = alt
    }
    
    private func canSave() -> Bool {
        guard MarkupEditor.selectionState.canInsert, argSrc != nil else { return false }
        return true
    }
    
    @objc private func selectImage() {
        let controller =  UIDocumentPickerViewController(forOpeningContentTypes: MarkupEditor.supportedImageTypes)
        controller.allowsMultipleSelection = false
        controller.delegate = self
        present(controller, animated: true)
    }
    
    private func dismiss() {
        dismiss(animated: true) {
            MarkupEditor.selectedWebView?.becomeFirstResponder()
        }
    }

    /// 根据需要保存当前选择的图片并关闭视图
    @objc private func save() {
        if canSave() && (src != savedSrc || alt != savedAlt) {
            saveImage {
                self.dismiss()
            }
        } else {
            dismiss()
        }
    }
    
    /// 取消插入图片操作并关闭视图
    @objc private func cancel() {
        if savedImageHasChanged() {
            // We saved something to the document that we want to abandon
            src = originalSrc ?? ""
            alt = originalAlt ?? ""
            saveImage {
                self.dismiss()
            }
        } else {
            // Use endModalInput because insertImage was never called to restore selection
            MarkupEditor.selectedWebView?.endModalInput {
                self.dismiss()
            }
        }
    }
    
    private func currentImageHasChanged() -> Bool {
        savedSrc == nil || (savedSrc != nil && savedSrc != src) || savedAlt != alt
    }
    
    private func savedImageHasChanged() -> Bool {
        (savedSrc != nil && savedSrc != originalSrc) || (savedAlt != nil && savedAlt != originalAlt)
    }
    
}

/// UITextViewDelegate 扩展
/// 处理文本输入相关的操作
extension ImageViewController: UITextViewDelegate {
    
    /// 当用户输入时更新src（注意：如果shouldChangeTextIn返回false则不会执行）
    func textViewDidChange(_ textView: UITextView) {
        if textView == srcView {
            src = textView.text
            srcViewLabel.isHidden = !textView.text.isEmpty
            setButtons()
        } else if textView == altView {
            alt = textView.text
            altViewLabel.isHidden = !textView.text.isEmpty
            setButtons()
        }
    }
    
    /// 当用户按下回车键时执行相应操作，Tab键在两个文本视图之间切换
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            if canSave() {
                save()
            } else {
                cancel()
            }
            return false
        } else if text == "\t" {
            if textView == srcView {
                altView.becomeFirstResponder()
                let selectedRange = altView.selectedTextRange
                if selectedRange == nil {
                    altView.selectedTextRange = altView.textRange(from: altView.endOfDocument, to: altView.endOfDocument)
                }
            } else if textView == altView {
                srcView.becomeFirstResponder()
                let selectedRange = srcView.selectedTextRange
                if selectedRange == nil {
                    srcView.selectedTextRange = srcView.textRange(from: srcView.endOfDocument, to: srcView.endOfDocument)
                }
            }
            if currentImageHasChanged() {
                saveImage()
            }
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        setTextViews()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        setTextViews()
    }
    
}

/// UIDocumentPickerDelegate 扩展
/// 处理本地图片文件的选择
extension ImageViewController: UIDocumentPickerDelegate {
    
    /// 使用标准的UIDocumentPickerViewController来选择本地图片
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first, url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        MarkupEditor.selectedWebView?.insertLocalImage(url: url) { cachedImageUrl in
            let relativeSrc = cachedImageUrl.relativeString
            self.src = relativeSrc
            self.savedSrc = relativeSrc
            self.srcView.text = relativeSrc
            self.srcViewLabel.isHidden = !self.srcView.text.isEmpty
            self.setButtons()
            self.setTextViews()
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        MarkupEditor.selectImage.value = false
        controller.dismiss(animated: true, completion: nil)
    }
    
}
