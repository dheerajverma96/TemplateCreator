//
//  ComponentModels.swift
//  DragAndDropTemplateCreator
//
//  Created by Dheeraj Verma on 17/08/25.
//

import SwiftUI

// MARK: - Component Types
enum ComponentType: String, CaseIterable, Codable {
    case text = "Text"
    case textArea = "TextArea"
    case image = "Image"
    case button = "Button"
    
    var systemImage: String {
        switch self {
        case .text: return "textformat"
        case .textArea: return "text.justify"
        case .image: return "photo"
        case .button: return "button.roundedtop.horizontal"
        }
    }
}

// MARK: - Canvas Component
struct CanvasComponent: Identifiable, Codable, Equatable {
    var id = UUID()
    var type: ComponentType
    var position: CGPoint
    var properties: ComponentProperties
    var isSelected: Bool = false
    
    static func == (lhs: CanvasComponent, rhs: CanvasComponent) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Component Properties
struct ComponentProperties: Codable {
    // Text Properties
    var text: String = "Sample Text"
    var fontSize: Double = 16
    var fontWeight: FontWeight = .normal
    var textColor: ColorData = ColorData(red: 0, green: 0, blue: 0, alpha: 1)
    var textAlign: TextAlignment = .leading
    
    // TextArea Properties  
    var textAreaContent: String = "Sample TextArea Content"
    
    // Image Properties
    var imageURL: String = ""
    var altText: String = ""
    var objectFit: ObjectFit = .fill
    var borderRadius: Double = 0
    var height: Double = 100
    var width: Double = 100
    
    // Button Properties
    var buttonText: String = "Button"
    var url: String = ""
    var padding: Double = 16
    var backgroundColor: ColorData = ColorData(red: 0, green: 0.5, blue: 1, alpha: 1)
    
    enum FontWeight: String, CaseIterable, Codable {
        case normal = "400 - Normal"
        case bold = "700 - Bold"
        
        var swiftUIWeight: Font.Weight {
            switch self {
            case .normal: return .regular
            case .bold: return .bold
            }
        }
    }
    
    enum ObjectFit: String, CaseIterable, Codable {
        case cover = "Cover"
        case contain = "Contain"
        case fill = "Fill"
        
        var contentMode: ContentMode {
            switch self {
            case .cover: return .fill
            case .contain: return .fit
            case .fill: return .fill
            }
        }
    }
    
    enum TextAlignment: String, CaseIterable, Codable {
        case leading = "Left"
        case center = "Center"
        case trailing = "Right"
        
        var swiftUIAlignment: SwiftUI.TextAlignment {
            switch self {
            case .leading: return .leading
            case .center: return .center
            case .trailing: return .trailing
            }
        }
    }
}

// MARK: - Color Data for Codable Support
struct ColorData: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double
    
    var color: Color {
        Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
    
    init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
    
    init(color: Color) {
        // Default values, would need proper color extraction for real implementation
        self.red = 0
        self.green = 0
        self.blue = 0
        self.alpha = 1
    }
}

// MARK: - Editor Snapshot for Undo/Redo
struct EditorSnapshot: Codable {
    let components: [CanvasComponent]
    let timestamp: Date
    
    init(components: [CanvasComponent]) {
        self.components = components
        self.timestamp = Date()
    }
}

// MARK: - Preview Device
enum PreviewDevice: String, CaseIterable, Codable {
    case mobile = "Mobile"
}