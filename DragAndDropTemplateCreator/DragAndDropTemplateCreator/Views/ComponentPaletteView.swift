//
//  ComponentPaletteView.swift
//  DragAndDropTemplateCreator
//
//  Created by Dheeraj Verma on 17/08/25.
//

import SwiftUI

// MARK: - Component Palette View
struct ComponentPaletteView: View {
    @ObservedObject var viewModel: ComponentPaletteViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Components")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(viewModel.availableComponents, id: \.self) { componentType in
                    ComponentPaletteItemView(
                        componentType: componentType,
                        viewModel: viewModel
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.vertical)
    }
}

// MARK: - Component Palette Item View
struct ComponentPaletteItemView: View {
    let componentType: ComponentType
    @ObservedObject var viewModel: ComponentPaletteViewModel
    @State private var dragOffset: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: componentType.systemImage)
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(componentType.rawValue)
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
        .offset(dragOffset)
        .gesture(
            DragGesture(coordinateSpace: .global)
                .onChanged { value in
                    dragOffset = value.translation
                    viewModel.startDragging(componentType)
                }
                .onEnded { value in
                    let screenWidth = UIScreen.main.bounds.width
                    
                    if viewModel.canDropComponent(at: value.location, screenWidth: screenWidth) {
                        let canvasPosition = viewModel.convertToCanvasPosition(
                            from: value.location,
                            screenWidth: screenWidth
                        )
                        viewModel.addComponentToCanvas(componentType, at: canvasPosition)
                    }
                    
                    dragOffset = .zero
                    viewModel.endDragging()
                }
        )
    }
}