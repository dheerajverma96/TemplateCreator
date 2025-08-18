//
//  PropertiesView.swift
//  DragAndDropTemplateCreator
//
//  Created by Dheeraj Verma on 17/08/25.
//

import SwiftUI

// MARK: - Properties View
struct PropertiesView: View {
    @ObservedObject var viewModel: PropertiesViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Properties")
                .font(.headline)
                .padding(.horizontal)
            
            if let selectedComponent = viewModel.selectedComponent {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Component Type Header
                        ComponentHeaderView(
                            component: selectedComponent,
                            viewModel: viewModel
                        )
                        
                        Divider()
                        
                        // Properties based on component type
                        switch selectedComponent.type {
                        case .text:
                            TextPropertiesView(viewModel: viewModel)
                        case .textArea:
                            TextAreaPropertiesView(viewModel: viewModel)
                        case .image:
                            ImagePropertiesView(viewModel: viewModel)
                        case .button:
                            ButtonPropertiesView(viewModel: viewModel)
                        }
                    }
                }
            } else {
                Spacer()
                VStack {
                    Text("Select a component to edit properties")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                Spacer()
            }
        }
        .padding(.vertical)
    }
}

// MARK: - Component Header View
struct ComponentHeaderView: View {
    let component: CanvasComponent
    @ObservedObject var viewModel: PropertiesViewModel
    
    var body: some View {
        HStack {
            Image(systemName: component.type.systemImage)
            Text(component.type.rawValue)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Spacer()
            
            Button("Delete") {
                viewModel.deleteSelectedComponent()
            }
            .foregroundColor(.red)
            .font(.caption)
        }
        .padding(.horizontal)
    }
}

// MARK: - Text Properties View
struct TextPropertiesView: View {
    @ObservedObject var viewModel: PropertiesViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Text Content
            PropertySection(title: "Content") {
                TextField("Text", text: Binding(
                    get: { viewModel.editingProperties.text },
                    set: { viewModel.updateText($0) }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Font Size
            PropertySection(title: "Font Size") {
                VStack {
                    HStack {
                        Text("\(Int(viewModel.editingProperties.fontSize))px")
                        Spacer()
                    }
                    Slider(
                        value: Binding(
                            get: { viewModel.editingProperties.fontSize },
                            set: { viewModel.updateFontSize($0) }
                        ),
                        in: 8...72,
                        step: 1
                    )
                }
            }
            
            // Font Weight
            PropertySection(title: "Font Weight") {
                Picker("Font Weight", selection: Binding(
                    get: { viewModel.editingProperties.fontWeight },
                    set: { viewModel.updateFontWeight($0) }
                )) {
                    ForEach(ComponentProperties.FontWeight.allCases, id: \.self) { weight in
                        Text(weight.rawValue).tag(weight)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            // Text Color
            PropertySection(title: "Color") {
                ColorPickerView(
                    colorData: Binding(
                        get: { viewModel.editingProperties.textColor },
                        set: { viewModel.updateTextColor($0) }
                    )
                )
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - TextArea Properties View
struct TextAreaPropertiesView: View {
    @ObservedObject var viewModel: PropertiesViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Content
            PropertySection(title: "Content") {
                TextEditor(text: Binding(
                    get: { viewModel.editingProperties.textAreaContent },
                    set: { viewModel.updateTextAreaContent($0) }
                ))
                .frame(minHeight: 60)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.3)))
            }
            
            // Font Size
            PropertySection(title: "Font Size") {
                VStack {
                    HStack {
                        Text("\(Int(viewModel.editingProperties.fontSize))px")
                        Spacer()
                    }
                    Slider(
                        value: Binding(
                            get: { viewModel.editingProperties.fontSize },
                            set: { viewModel.updateFontSize($0) }
                        ),
                        in: 8...72,
                        step: 1
                    )
                }
            }
            
            // Text Color
            PropertySection(title: "Color") {
                ColorPickerView(
                    colorData: Binding(
                        get: { viewModel.editingProperties.textColor },
                        set: { viewModel.updateTextColor($0) }
                    )
                )
            }
            
            // Text Align
            PropertySection(title: "Text Align") {
                HStack {
                    ForEach(ComponentProperties.TextAlignment.allCases, id: \.self) { alignment in
                        Button(alignment.rawValue) {
                            viewModel.updateTextAlignment(alignment)
                        }
                        .foregroundColor(viewModel.editingProperties.textAlign == alignment ? .white : .blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(viewModel.editingProperties.textAlign == alignment ? Color.blue : Color.blue.opacity(0.1))
                        .cornerRadius(6)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Image Properties View
struct ImagePropertiesView: View {
    @ObservedObject var viewModel: PropertiesViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Image URL
            PropertySection(title: "Image URL") {
                TextField("https://example.com/image.jpg", text: Binding(
                    get: { viewModel.editingProperties.imageURL },
                    set: { viewModel.updateImageURL($0) }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Alt Text
            PropertySection(title: "Alt Text") {
                TextField("Alternative text", text: Binding(
                    get: { viewModel.editingProperties.altText },
                    set: { viewModel.updateAltText($0) }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Object Fit
            PropertySection(title: "Object Fit") {
                Picker("Object Fit", selection: Binding(
                    get: { viewModel.editingProperties.objectFit },
                    set: { viewModel.updateObjectFit($0) }
                )) {
                    ForEach(ComponentProperties.ObjectFit.allCases, id: \.self) { fit in
                        Text(fit.rawValue).tag(fit)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }
            
            // Border Radius
            PropertySection(title: "Border Radius") {
                VStack {
                    HStack {
                        Text("\(Int(viewModel.editingProperties.borderRadius))px")
                        Spacer()
                    }
                    Slider(
                        value: Binding(
                            get: { viewModel.editingProperties.borderRadius },
                            set: { viewModel.updateBorderRadius($0) }
                        ),
                        in: 0...50,
                        step: 1
                    )
                }
            }
            
            // Width
            PropertySection(title: "Width") {
                VStack {
                    HStack {
                        Text("\(Int(viewModel.editingProperties.width))px")
                        Spacer()
                    }
                    Slider(
                        value: Binding(
                            get: { viewModel.editingProperties.width },
                            set: { viewModel.updateWidth($0) }
                        ),
                        in: 50...500,
                        step: 1
                    )
                }
            }
            
            // Height
            PropertySection(title: "Height") {
                VStack {
                    HStack {
                        Text("\(Int(viewModel.editingProperties.height))px")
                        Spacer()
                    }
                    Slider(
                        value: Binding(
                            get: { viewModel.editingProperties.height },
                            set: { viewModel.updateHeight($0) }
                        ),
                        in: 50...500,
                        step: 1
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Button Properties View
struct ButtonPropertiesView: View {
    @ObservedObject var viewModel: PropertiesViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // URL
            PropertySection(title: "URL") {
                TextField("https://example.com", text: Binding(
                    get: { viewModel.editingProperties.url },
                    set: { viewModel.updateURL($0) }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Button Text
            PropertySection(title: "Button Text") {
                TextField("Button", text: Binding(
                    get: { viewModel.editingProperties.buttonText },
                    set: { viewModel.updateButtonText($0) }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Font Size
            PropertySection(title: "Font Size") {
                VStack {
                    HStack {
                        Text("\(Int(viewModel.editingProperties.fontSize))px")
                        Spacer()
                    }
                    Slider(
                        value: Binding(
                            get: { viewModel.editingProperties.fontSize },
                            set: { viewModel.updateFontSize($0) }
                        ),
                        in: 8...36,
                        step: 1
                    )
                }
            }
            
            // Padding
            PropertySection(title: "Padding") {
                VStack {
                    HStack {
                        Text("\(Int(viewModel.editingProperties.padding))px")
                        Spacer()
                    }
                    Slider(
                        value: Binding(
                            get: { viewModel.editingProperties.padding },
                            set: { viewModel.updatePadding($0) }
                        ),
                        in: 4...40,
                        step: 1
                    )
                }
            }
            
            // Background Color
            PropertySection(title: "Background Color") {
                ColorPickerView(
                    colorData: Binding(
                        get: { viewModel.editingProperties.backgroundColor },
                        set: { viewModel.updateBackgroundColor($0) }
                    )
                )
            }
            
            // Text Color
            PropertySection(title: "Text Color") {
                ColorPickerView(
                    colorData: Binding(
                        get: { viewModel.editingProperties.textColor },
                        set: { viewModel.updateTextColor($0) }
                    )
                )
            }
            
            // Border Radius
            PropertySection(title: "Border Radius") {
                VStack {
                    HStack {
                        Text("\(Int(viewModel.editingProperties.borderRadius))px")
                        Spacer()
                    }
                    Slider(
                        value: Binding(
                            get: { viewModel.editingProperties.borderRadius },
                            set: { viewModel.updateBorderRadius($0) }
                        ),
                        in: 0...25,
                        step: 1
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Helper Views
struct PropertySection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            content
        }
    }
}

struct ColorPickerView: View {
    @Binding var colorData: ColorData
    
    var body: some View {
        ColorPicker("", selection: Binding(
            get: { colorData.color },
            set: { newColor in
                // Convert Color to ColorData (simplified)
                colorData = ColorData(color: newColor)
            }
        ))
        .labelsHidden()
        .frame(height: 40)
    }
}