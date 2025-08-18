//
//  PreviewViewModel.swift
//  DragAndDropTemplateCreator
//
//  Created by Dheeraj Verma on 17/08/25.
//

import SwiftUI
import Combine

// MARK: - Enhanced Preview Device
enum EnhancedPreviewDevice: String, CaseIterable {
    case mobile = "iPhone"
    case tablet = "iPad"
    
    var dimensions: CGSize {
        switch self {
        case .mobile: return CGSize(width: 375, height: 812)
        case .tablet: return CGSize(width: 768, height: 1024)
        }
    }
    
    var systemImage: String {
        switch self {
        case .mobile: return "iphone"
        case .tablet: return "ipad"
        }
    }
}

// MARK: - Preview ViewModel
class PreviewViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedDevice: EnhancedPreviewDevice = .mobile
    @Published var isFullScreen: Bool = false
    @Published var showExportOptions: Bool = false
    @Published var isPreviewPresented: Bool = false
    
    // MARK: - Private Properties
    private weak var editorViewModel: EditorViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    var components: [CanvasComponent] {
        editorViewModel?.components ?? []
    }
    
    var deviceDimensions: CGSize {
        selectedDevice.dimensions
    }
    
    var previewWidth: CGFloat {
        switch editorViewModel?.previewDevice {
        case .mobile: return 375
        case .none: return 375
        }
    }
    
    var previewHeight: CGFloat {
        switch editorViewModel?.previewDevice {
        case .mobile: return 600
        case .none: return 600
        }
    }
    
    var componentCount: Int {
        components.count
    }
    
    // MARK: - Initialization
    init(editorViewModel: EditorViewModel) {
        self.editorViewModel = editorViewModel
    }
    
    // MARK: - Public Methods
    func presentPreview() {
        isPreviewPresented = true
    }
    
    func dismissPreview() {
        isPreviewPresented = false
        isFullScreen = false
    }
    
    func toggleFullScreen() {
        isFullScreen.toggle()
    }
    
    func selectDevice(_ device: EnhancedPreviewDevice) {
        selectedDevice = device
    }
    
    func showExportSheet() {
        showExportOptions = true
    }
    
    func hideExportSheet() {
        showExportOptions = false
    }
    
    func copyHTMLToClipboard() {
        guard let html = editorViewModel?.generateHTML() else { return }
        UIPasteboard.general.string = html
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    func shareHTML() -> String {
        return editorViewModel?.generateHTML() ?? ""
    }
    
    func updateInlinePreviewDevice(_ device: PreviewDevice) {
        editorViewModel?.setPreviewDevice(device)
    }
    
    func toggleInlinePreview() {
        editorViewModel?.togglePreviewMode()
    }
    
    var isInlinePreviewMode: Bool {
        editorViewModel?.isPreviewMode ?? false
    }
    
    var inlinePreviewDevice: PreviewDevice {
        editorViewModel?.previewDevice ?? .mobile
    }
}