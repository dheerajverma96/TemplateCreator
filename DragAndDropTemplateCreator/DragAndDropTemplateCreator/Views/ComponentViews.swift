//
//  ComponentViews.swift
//  DragAndDropTemplateCreator
//
//  Created by Dheeraj Verma on 17/08/25.
//

import SwiftUI

// MARK: - Editable Text View
struct EditableTextView: View {
    let component: CanvasComponent
    @ObservedObject var editorViewModel: EditorViewModel
    @State private var isEditing: Bool = false
    @State private var editingText: String = ""
    
    var body: some View {
        if isEditing {
            TextField("Enter text", text: $editingText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    var updatedProperties = component.properties
                    updatedProperties.text = editingText
                    editorViewModel.updateComponentProperties(component.id, properties: updatedProperties)
                    isEditing = false
                }
                .onAppear {
                    editingText = component.properties.text
                }
        } else {
            Text(component.properties.text)
                .font(.system(size: component.properties.fontSize, weight: component.properties.fontWeight.swiftUIWeight))
                .foregroundColor(component.properties.textColor.color)
                .onTapGesture(count: 2) {
                    isEditing = true
                }
        }
    }
}

// MARK: - Editable TextArea View
struct EditableTextAreaView: View {
    let component: CanvasComponent
    @ObservedObject var editorViewModel: EditorViewModel
    @State private var isEditing: Bool = false
    @State private var editingText: String = ""
    
    var body: some View {
        if isEditing {
            TextEditor(text: $editingText)
                .frame(minWidth: 150, minHeight: 60)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray))
                .onTapGesture(count: 2) {
                    var updatedProperties = component.properties
                    updatedProperties.textAreaContent = editingText
                    editorViewModel.updateComponentProperties(component.id, properties: updatedProperties)
                    isEditing = false
                }
                .onAppear {
                    editingText = component.properties.textAreaContent
                }
        } else {
            Text(component.properties.textAreaContent)
                .font(.system(size: component.properties.fontSize))
                .foregroundColor(component.properties.textColor.color)
                .multilineTextAlignment(component.properties.textAlign.swiftUIAlignment)
                .frame(minWidth: 150, minHeight: 60)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray.opacity(0.3)))
                .onTapGesture(count: 2) {
                    isEditing = true
                }
        }
    }
}

// MARK: - Image Component View
struct ImageComponentView: View {
    let component: CanvasComponent
    
    var body: some View {
        AsyncImage(url: URL(string: component.properties.imageURL)) { image in
            image
                .resizable()
                .aspectRatio(contentMode: component.properties.objectFit.contentMode)
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .overlay(
                    VStack {
                        Image(systemName: "photo")
                        Text("Image")
                            .font(.caption)
                    }
                )
        }
        .frame(width: component.properties.width, height: component.properties.height)
        .cornerRadius(component.properties.borderRadius)
    }
}

// MARK: - Button Component View
struct ButtonComponentView: View {
    let component: CanvasComponent
    
    var body: some View {
        Button(component.properties.buttonText) {
            // Handle button tap if needed
        }
        .font(.system(size: component.properties.fontSize))
        .foregroundColor(component.properties.textColor.color)
        .padding(component.properties.padding)
        .background(component.properties.backgroundColor.color)
        .cornerRadius(component.properties.borderRadius)
    }
}

// MARK: - Interactive Preview Component View
struct InteractivePreviewComponentView: View {
    let component: CanvasComponent
    
    var body: some View {
        Group {
            switch component.type {
            case .text:
                Text(component.properties.text)
                    .font(.system(size: component.properties.fontSize, weight: component.properties.fontWeight.swiftUIWeight))
                    .foregroundColor(component.properties.textColor.color)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                
            case .textArea:
                Text(component.properties.textAreaContent)
                    .font(.system(size: component.properties.fontSize))
                    .foregroundColor(component.properties.textColor.color)
                    .multilineTextAlignment(component.properties.textAlign.swiftUIAlignment)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(minWidth: 150, alignment: .leading)
                
            case .image:
                AsyncImage(url: URL(string: component.properties.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: component.properties.objectFit.contentMode)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay(
                            VStack {
                                Image(systemName: "photo")
                                    .font(.title2)
                                Text("Image")
                                    .font(.caption)
                            }
                            .foregroundColor(.gray)
                        )
                }
                .frame(width: component.properties.width, height: component.properties.height)
                .cornerRadius(component.properties.borderRadius)
                
            case .button:
                Button(action: {
                    // Handle button tap - could open URL if provided
                    if !component.properties.url.isEmpty,
                       let url = URL(string: component.properties.url) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text(component.properties.buttonText)
                        .font(.system(size: component.properties.fontSize))
                        .foregroundColor(component.properties.textColor.color)
                        .padding(component.properties.padding)
                        .background(component.properties.backgroundColor.color)
                        .cornerRadius(component.properties.borderRadius)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}