//
//  CanvasView.swift
//  DragAndDropTemplateCreator
//
//  Created by Dheeraj Verma on 17/08/25.
//

import SwiftUI

// MARK: - Canvas View
struct CanvasView: View {
    @ObservedObject var editorViewModel: EditorViewModel
    @ObservedObject var previewViewModel: PreviewViewModel
    
    var body: some View {
        ZStack {
            // Canvas Background
            Rectangle()
                .fill(Color.gray.opacity(0.05))
                .onTapGesture {
                    editorViewModel.deselectComponent()
                }
            
            if previewViewModel.isInlinePreviewMode {
                InlinePreviewView(
                    editorViewModel: editorViewModel,
                    previewViewModel: previewViewModel
                )
            } else {
                EditingCanvasView(editorViewModel: editorViewModel)
            }
        }
    }
}

// MARK: - Editing Canvas View
struct EditingCanvasView: View {
    @ObservedObject var editorViewModel: EditorViewModel
    
    var body: some View {
        ForEach(editorViewModel.components) { component in
            CanvasComponentView(
                component: component,
                editorViewModel: editorViewModel
            )
            .position(component.position)
        }
    }
}

// MARK: - Inline Preview View
struct InlinePreviewView: View {
    @ObservedObject var editorViewModel: EditorViewModel
    @ObservedObject var previewViewModel: PreviewViewModel
    @State private var showingEnhancedPreview: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Preview Controls
            VStack(spacing: 12) {
                HStack {
                    Text("Quick Preview")
                        .font(.headline)
                    
                    Spacer()
                    
                    Button("Full Preview") {
                        showingEnhancedPreview = true
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                }
                
                HStack {
                    HStack {
                        Image(systemName: "iphone")
                        Text("Mobile Preview")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        previewViewModel.copyHTMLToClipboard()
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
                
                // Resolution Info
                HStack {
                    Text("Resolution: \(Int(previewViewModel.previewWidth)) × \(Int(previewViewModel.previewHeight))")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(previewViewModel.componentCount) components")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            // Preview Content
            ScrollView {
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .frame(
                            width: previewViewModel.previewWidth,
                            height: max(previewViewModel.previewHeight, CGFloat(previewViewModel.componentCount * 100 + 200))
                        )
                        .shadow(radius: 2)
                    
                    ForEach(editorViewModel.components) { component in
                        InteractivePreviewComponentView(component: component)
                            .position(component.position)
                    }
                }
                .frame(width: previewViewModel.previewWidth)
            }
            .frame(maxWidth: .infinity)
            .background(Color.gray.opacity(0.1))
        }
        .sheet(isPresented: $showingEnhancedPreview) {
            EnhancedPreviewView(
                viewModel: previewViewModel,
                isPresented: $showingEnhancedPreview
            )
        }
    }
}

// MARK: - Canvas Component View
struct CanvasComponentView: View {
    let component: CanvasComponent
    @ObservedObject var editorViewModel: EditorViewModel
    @State private var dragOffset: CGSize = .zero
    
    var isSelected: Bool {
        editorViewModel.selectedComponentId == component.id
    }
    
    var body: some View {
        Group {
            switch component.type {
            case .text:
                EditableTextView(component: component, editorViewModel: editorViewModel)
            case .textArea:
                EditableTextAreaView(component: component, editorViewModel: editorViewModel)
            case .image:
                ImageComponentView(component: component)
            case .button:
                ButtonComponentView(component: component)
            }
        }
        .overlay(
            isSelected ? 
            Rectangle()
                .stroke(Color.blue, lineWidth: 2)
                .background(Color.blue.opacity(0.1))
            : nil
        )
        .offset(dragOffset)
        .gesture(
            DragGesture()
                .onChanged { value in
                    dragOffset = value.translation
                }
                .onEnded { value in
                    let newPosition = CGPoint(
                        x: component.position.x + value.translation.width,
                        y: component.position.y + value.translation.height
                    )
                    editorViewModel.updateComponentPosition(component.id, to: newPosition)
                    dragOffset = .zero
                }
        )
        .onTapGesture {
            editorViewModel.selectComponent(component)
        }
    }
}