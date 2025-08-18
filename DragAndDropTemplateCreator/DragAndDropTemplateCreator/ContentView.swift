//
//  ContentView.swift
//  DragAndDropTemplateCreator
//
//  Created by Dheeraj Verma on 17/08/25.
//

import SwiftUI

struct ContentView: View {
    // MARK: - ViewModels
    @StateObject private var editorViewModel = EditorViewModel()
    @StateObject private var componentPaletteViewModel: ComponentPaletteViewModel
    @StateObject private var propertiesViewModel: PropertiesViewModel
    @StateObject private var previewViewModel: PreviewViewModel
    
    // MARK: - State
    @State private var showingEnhancedPreview: Bool = false
    
    // MARK: - Initialization
    init() {
        let editorVM = EditorViewModel()
        self._editorViewModel = StateObject(wrappedValue: editorVM)
        self._componentPaletteViewModel = StateObject(wrappedValue: ComponentPaletteViewModel(editorViewModel: editorVM))
        self._propertiesViewModel = StateObject(wrappedValue: PropertiesViewModel(editorViewModel: editorVM))
        self._previewViewModel = StateObject(wrappedValue: PreviewViewModel(editorViewModel: editorVM))
    }
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Left Panel - Component Palette (20%)
                    ComponentPaletteView(viewModel: componentPaletteViewModel)
                        .frame(width: geometry.size.width * 0.2)
                        .background(Color.gray.opacity(0.1))
                    
                    // Middle Panel - Canvas (60%)
                    CanvasView(
                        editorViewModel: editorViewModel,
                        previewViewModel: previewViewModel
                    )
                    .frame(width: geometry.size.width * 0.6)
                    .background(Color.white)
                    
                    // Right Panel - Properties (20%)
                    PropertiesView(viewModel: propertiesViewModel)
                        .frame(width: geometry.size.width * 0.2)
                        .background(Color.gray.opacity(0.1))
                }
            }
            .navigationTitle("Template Creator")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    ToolbarButtonsView(
                        editorViewModel: editorViewModel,
                        previewViewModel: previewViewModel,
                        showingEnhancedPreview: $showingEnhancedPreview
                    )
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingEnhancedPreview) {
            EnhancedPreviewView(
                viewModel: previewViewModel,
                isPresented: $showingEnhancedPreview
            )
        }
    }
}

// MARK: - Toolbar Buttons View
struct ToolbarButtonsView: View {
    @ObservedObject var editorViewModel: EditorViewModel
    @ObservedObject var previewViewModel: PreviewViewModel
    @Binding var showingEnhancedPreview: Bool
    
    var body: some View {
        HStack {
            Button(action: { editorViewModel.undo() }) {
                Image(systemName: "arrow.uturn.backward")
            }
            .disabled(!editorViewModel.canUndo)
            
            Button(action: { editorViewModel.redo() }) {
                Image(systemName: "arrow.uturn.forward")
            }
            .disabled(!editorViewModel.canRedo)
            
            Button(action: { previewViewModel.toggleInlinePreview() }) {
                Image(systemName: previewViewModel.isInlinePreviewMode ? "eye.slash" : "eye")
            }
            
            Button(action: { showingEnhancedPreview = true }) {
                Image(systemName: "rectangle.on.rectangle")
            }
            
            Menu {
                Button("Copy HTML") {
                    previewViewModel.copyHTMLToClipboard()
                }
                
                Button("Clear Canvas") {
                    editorViewModel.clearAllComponents()
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
}

#Preview {
    ContentView()
}