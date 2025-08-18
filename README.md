[README.md](https://github.com/user-attachments/files/21828330/README.md)
# iOS Drag-and-Drop Template Creator

A comprehensive iOS application built with SwiftUI that provides drag-and-drop template creation functionality similar to Beefree and GrapesJS, but optimized for native iOS experience.

## 🎯 Features

### Core Functionality
- **Three-Panel Layout**: 20% (Palette) - 60% (Canvas) - 20% (Properties)
- **Component Palette**: Pre-defined components (Text, TextArea, Image, Button)
- **Native Drag & Drop**: Built from scratch using SwiftUI drag gestures
- **Freeform Canvas**: Components can be positioned anywhere and moved freely
- **Dynamic Properties Panel**: Context-aware property editing based on selected component
- **Real-Time Updates**: Instant visual feedback when properties are modified

### Advanced Features
- **Undo/Redo System**: 50-step history with complete state management
- **Custom Inline Editor**: Double-tap to edit Text and TextArea components directly
- **Enhanced Preview System**: Comprehensive preview with multiple modes and device simulation
- **Export Functionality**: Generate and copy HTML to clipboard with advanced sharing options
- **Persistence**: Auto-save using UserDefaults for seamless session continuity

## 🏗️ Architecture

### File Structure (MVVM Architecture)
```
DragAndDropTemplateCreator/
├── Models/
│   └── ComponentModels.swift      # Pure data models without business logic
├── ViewModels/
│   ├── EditorViewModel.swift      # Core editor state and business logic
│   ├── ComponentPaletteViewModel.swift  # Component palette management
│   ├── PropertiesViewModel.swift  # Property editing logic
│   └── PreviewViewModel.swift     # Preview functionality
├── Views/
│   ├── CanvasView.swift          # Main canvas and component rendering
│   ├── ComponentPaletteView.swift # Component selection interface
│   ├── PropertiesView.swift      # Dynamic property editing panels
│   ├── ComponentViews.swift      # Individual component representations
│   └── EnhancedPreviewView.swift # Comprehensive preview system
├── ContentView.swift              # Main app coordinator with dependency injection
├── DragAndDropTemplateCreatorApp.swift # App entry point
└── Assets.xcassets/               # App icons and assets
```

## 🎯 MVVM Architecture

This app follows a clean **Model-View-ViewModel (MVVM)** architecture pattern for maintainable and testable code:

### **📦 Models Layer**
**`ComponentModels.swift`** - Pure data structures without business logic:
- `ComponentType`: Enum defining available component types
- `CanvasComponent`: Represents components with position and properties  
- `ComponentProperties`: Unified properties for all component types
- `EditorSnapshot`: Immutable state snapshots for undo/redo
- `ColorData`: Codable color representation

### **🧠 ViewModels Layer**
Business logic and state management separated from UI:

**`EditorViewModel.swift`** - Core editor functionality:
- Component management (add, update, delete, move)
- Undo/redo system with 50-step history
- Persistence via UserDefaults
- HTML generation

**`ComponentPaletteViewModel.swift`** - Component selection logic:
- Available components management
- Drag and drop validation
- Canvas position conversion

**`PropertiesViewModel.swift`** - Property editing logic:
- Reactive property updates using Combine
- Type-safe property modifications
- Real-time component synchronization

**`PreviewViewModel.swift`** - Preview functionality:
- Multi-device preview management
- Export and sharing capabilities
- Preview mode state management

### **🎨 Views Layer**
Pure UI components with no business logic:

**`ContentView.swift`** - Main coordinator with dependency injection
**`CanvasView.swift`** - Interactive canvas and component rendering
**`ComponentPaletteView.swift`** - Component selection interface
**`PropertiesView.swift`** - Dynamic property editing panels
**`ComponentViews.swift`** - Individual component representations
**`EnhancedPreviewView.swift`** - Comprehensive preview system

### **🔗 Dependency Injection**
Clean dependency management:
- ViewModels are injected into Views via initializers
- Single source of truth with `EditorViewModel` as primary state manager
- Loose coupling between layers for easy testing and modification

## 🎯 Enhanced Preview System

The app features a comprehensive preview system optimized for mobile-first design:

### **Quick Preview (Inline)**
- **Mobile-Focused**: Optimized for mobile template preview (375 × 600)
- **Real-time Updates**: See changes instantly as you edit
- **Resolution Display**: Shows current viewport dimensions
- **Component Counter**: Displays total number of components
- **Quick Export**: One-tap HTML copy to clipboard

### **Full Preview (Modal)**
- **Device Frames**: Realistic iPhone and iPad frames
- **Multiple Devices**: iPhone and iPad with accurate dimensions
- **Full-Screen Mode**: Immersive preview experience
- **Interactive Components**: Functional buttons with URL navigation
- **Export Options**: Comprehensive sharing and export tools

### **Preview Features**
- **Mobile-First Design**: Focused on mobile template creation
- **Device Simulation**: Accurate iPhone and iPad dimensions and frames
- **Interactive Elements**: Buttons work and can open URLs
- **Responsive Layout**: Components maintain positioning across devices
- **Export Integration**: Direct export from preview mode

## 🎨 Component Types & Properties

### Text Component
- **Font Size**: 8-72px slider
- **Font Weight**: Normal (400) / Bold (700) dropdown
- **Color**: Color picker
- **Inline Editing**: Double-tap to edit content

### TextArea Component
- **Font Size**: 8-72px slider  
- **Color**: Color picker
- **Text Align**: Left/Center/Right button group
- **Inline Editing**: Double-tap to edit content

### Image Component
- **Image URL**: Text input
- **Alt Text**: Text input
- **Object Fit**: Cover/Contain/Fill dropdown
- **Border Radius**: 0-50px slider
- **Width**: 50-500px slider
- **Height**: 50-500px slider

### Button Component
- **URL**: Text input
- **Button Text**: Text input
- **Font Size**: 8-36px slider
- **Padding**: 4-40px slider
- **Background Color**: Color picker
- **Text Color**: Color picker
- **Border Radius**: 0-25px slider

## 🚀 Usage

### Creating Templates
1. **Drag Components**: Drag any component from the left palette to the canvas
2. **Position Components**: Drag components around the canvas to position them
3. **Edit Properties**: Select a component and modify its properties in the right panel
4. **Inline Editing**: Double-tap Text/TextArea components to edit content directly

### Canvas Operations
- **Select Component**: Tap any component on canvas
- **Move Component**: Drag selected component to new position
- **Delete Component**: Select component and tap "Delete" in properties panel

### History Management
- **Undo**: Use toolbar undo button (supports 50 steps)
- **Redo**: Use toolbar redo button
- **Auto-Save**: Changes are automatically saved to device storage

### Preview & Export
- **Quick Preview**: Use eye icon in toolbar for inline preview mode
- **Full Preview**: Use rectangle icon in toolbar for comprehensive preview modal
- **Device Selection**: Choose from iPhone or iPad simulation
- **Full-Screen Preview**: Immersive preview experience with device frames
- **Interactive Preview**: Buttons are functional and can open URLs
- **Export Options**: Multiple export methods including copy, share, and view source
- **Device Frames**: Realistic device bezels for accurate preview

## 🔧 Technical Implementation

### Drag & Drop System
- Custom implementation using SwiftUI `DragGesture`
- Global coordinate system for cross-panel dragging
- Visual feedback with drag offset animations

### State Management
- `EditorState` as single source of truth
- `@Published` properties for automatic UI updates
- Efficient history snapshots for undo/redo

### Persistence
- JSON encoding/decoding for component serialization
- UserDefaults for automatic session persistence
- Robust error handling for data corruption

### HTML Export
- Dynamic HTML generation with inline CSS
- Responsive design considerations
- Cross-browser compatibility

## 🎯 Design Principles

### User Experience
- **Intuitive Interface**: Familiar three-panel layout similar to professional design tools
- **Visual Feedback**: Clear selection indicators and drag states
- **Accessibility**: Native iOS accessibility support through SwiftUI

### Performance
- **Optimized Rendering**: Efficient SwiftUI view updates
- **Memory Management**: Automatic cleanup of unused components
- **Smooth Animations**: Native iOS animation system for fluid interactions

### Extensibility
- **Modular Architecture**: Easy to add new component types
- **Property System**: Flexible property configuration for different components
- **Export Format**: Extensible HTML generation system

## 🔮 Future Enhancements

### Potential Features
- **Custom Component Creation**: Allow users to create custom component types
- **Template Library**: Save and load predefined templates
- **Collaboration**: Multi-user editing capabilities
- **Advanced Styling**: CSS class management and custom styling
- **Responsive Breakpoints**: Define behavior for different screen sizes

### Technical Improvements
- **Component Grouping**: Group multiple components for bulk operations
- **Snap-to-Grid**: Optional grid system for precise alignment
- **Layer Management**: Z-index control and layer organization
- **Animation Support**: Add component animations and transitions

## 📱 Requirements

- **iOS 18.5+**
- **Xcode 16+**
- **SwiftUI Framework**

## 🏃‍♂️ Getting Started

1. **Open Project**: Launch `DragAndDropTemplateCreator.xcodeproj` in Xcode
2. **Select Target**: Choose iPhone simulator or device
3. **Build & Run**: Use Cmd+R to build and run the application
4. **Start Creating**: Begin dragging components from the palette to create your template

## 📝 Notes

- Components automatically save to device storage
- The app supports both portrait and landscape orientations
- All drag and drop functionality is built using native iOS APIs
- No third-party libraries required - pure SwiftUI implementation

This application demonstrates modern iOS development practices while providing a powerful and intuitive template creation experience.
