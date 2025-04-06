import SwiftUI

//struct ArticleEditView: View {
//    @Environment(\.theme) private var theme
//    @Environment(\.colorScheme) private var colorScheme
//    
//    @ObservedObject private var state: RichEditorState
//    @State private var isInspectorPresented = false
//    @State private var fileName: String = ""
//    @State private var exportFormat: RichTextDataFormat? = nil
//    @State private var otherExportFormat: RichTextExportOption? = nil
//    @State private var exportService: StandardRichTextExportService = .init()
//    
//    @Binding var isEditView: Bool
//    
//    init(state: RichEditorState? = nil, isEditView: Binding<Bool>) {
//        if let state {
//            self.state = state
//        } else {
//            if let richText = readJSONFromFile(
//                fileName: "Sample_json",
//                type: RichText.self)
//            {
//                self.state = .init(richText: richText)
//            } else {
//                self.state = .init(input: "Hello World!")
//            }
//        }
//        self._isEditView = isEditView
//    }
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                RichTextEditor(
//                    context: _state,
//                    viewConfiguration: { _ in
//                        
//                    }
//                )
//                .background(
//                    colorScheme == .dark ? .gray.opacity(0.3) : Color.white
//                )
//                .cornerRadius(10)
//                
//                RichTextKeyboardToolbar(
//                    context: state,
//                    leadingButtons: { $0 },
//                    trailingButtons: { $0 },
//                    formatSheet: { $0 }
//                )
//            }
//            .inspector(isPresented: $isInspectorPresented) {
//                RichTextFormat.Sidebar(context: state)
//            }
//            .padding(8)
//            .toolbar {
//                ToolbarItemGroup(placement: .automatic) {
//                    toolBarGroup
//                }
//            }
//            .background(colorScheme == .dark ? .black : .gray.opacity(0.07))
//            .navigationBarTitleDisplayMode(.inline)
//            .alert("Enter file name", isPresented: getBindingAlert()) {
//                TextField("Enter file name", text: $fileName)
//                Button("OK", action: submit)
//            } message: {
//                Text("Please enter file name")
//            }
//            .focusedValue(\.richEditorState, state)
//            .toolbarRole(.automatic)
//            .richTextFormatSheetConfig(.init(colorPickers: colorPickers))
//            .richTextFormatSidebarConfig(
//                .init(
//                    colorPickers: colorPickers,
//                    fontPicker: isMac
//                )
//            )
//            .richTextFormatToolbarConfig(.init(colorPickers: []))
//            .navigationTitle("文章编辑")
//        }
//    }
//    
//    var toolBarGroup: some View {
//        return Group {
//            RichTextExportMenu.init(
//                formatAction: { format in
//                    exportFormat = format
//                },
//                otherOptionAction: { format in
//                    otherExportFormat = format
//                }
//            )
//            .frame(width: 25, alignment: .center)
//            Button(
//                action: {
//                    print("Exported JSON == \(state.outputAsString())")
//                },
//                label: {
//                    Image(systemName: "printer.inverse")
//                }
//            )
//            .frame(width: 25, alignment: .center)
//            Toggle(isOn: $isInspectorPresented) {
//                Image.richTextFormatBrush
//                    .resizable()
//                    .aspectRatio(1, contentMode: .fit)
//            }
//            .frame(width: 25, alignment: .center)
//        }
//    }
//    
//    func getBindingAlert() -> Binding<Bool> {
//        .init(
//            get: { exportFormat != nil || otherExportFormat != nil },
//            set: { newValue in
//                exportFormat = nil
//                otherExportFormat = nil
//            })
//    }
//    
//    func submit() {
//        guard !fileName.isEmpty else { return }
//        var path: URL?
//        
//        if let exportFormat {
//            path = try? exportService.generateExportFile(
//                withName: fileName, content: state.attributedString,
//                format: exportFormat)
//        }
//        if let otherExportFormat {
//            switch otherExportFormat {
//            case .pdf:
//                path = try? exportService.generatePdfExportFile(
//                    withName: fileName, content: state.attributedString)
//            case .json:
//                path = try? exportService.generateJsonExportFile(
//                    withName: fileName, content: state.richText)
//            }
//        }
//        if let path {
//            print("Exported at path == \(path)")
//        }
//    }
//}

//extension ArticleEditView {
//    
//    var isMac: Bool {
//#if os(macOS)
//        true
//#else
//        false
//#endif
//    }
//    
//    var colorPickers: [RichTextColor] {
//        [.foreground, .background]
//    }
//    
//    var formatToolbarEdge: VerticalEdge {
//        isMac ? .top : .bottom
//    }
//}
//
//internal func readJSONFromFile<T: Decodable>(
//    fileName: String,
//    type: T.Type,
//    bundle: Bundle? = nil
//) -> T? {
//    if let url = (bundle ?? Bundle.main)
//        .url(forResource: fileName, withExtension: "json")
//    {
//        do {
//            let data = try Data(contentsOf: url)
//            let decoder = JSONDecoder()
//            let jsonData = try decoder.decode(T.self, from: data)
//            return jsonData
//        } catch {
//            print("JSONUtils: error - \(error)")
//        }
//    }
//    return nil
//}
//
//internal class RichBundleFakeClass {}
//
//extension Bundle {
//    static var richBundle: Bundle {
//        return Bundle(for: RichBundleFakeClass.self)
//    }
//}
//
//func encode<T: Encodable>(model: T?) throws -> String? {
//    guard let model else { return nil }
//    do {
//        let jsonData = try JSONEncoder().encode(model)
//        let jsonString = String(data: jsonData, encoding: .utf8)
//        return jsonString
//    } catch {
//        throw error
//    }
//}
//
//func decode<T: Decodable>(json string: String) throws -> T? {
//    guard let data = string.data(using: .utf8) else { return nil }
//    do {
//        let content = try JSONDecoder().decode(T.self, from: data)
//        return content
//    } catch {
//        throw error
//    }
//}
