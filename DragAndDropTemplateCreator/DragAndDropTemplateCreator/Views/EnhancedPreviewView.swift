//
//  EnhancedPreviewView.swift
//  DragAndDropTemplateCreator
//
//  Created by Dheeraj Verma on 17/08/25.
//

import SwiftUI

// MARK: - Enhanced Preview View
struct EnhancedPreviewView: View {
    @ObservedObject var viewModel: PreviewViewModel
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Preview Controls
                    if !viewModel.isFullScreen {
                        previewControls
                            .padding()
                            .background(Color(.systemBackground))
                            .shadow(radius: 1)
                    }
                    
                    // Preview Content
                    ZStack {
                        Color(.systemGroupedBackground)
                            .ignoresSafeArea()
                        
                        if viewModel.isFullScreen {
                            fullScreenPreview
                        } else {
                            deviceFramePreview(in: geometry)
                        }
                    }
                }
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { viewModel.showExportSheet() }) {
                            Label("Export HTML", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: { viewModel.copyHTMLToClipboard() }) {
                            Label("Copy HTML", systemImage: "doc.on.clipboard")
                        }
                        
                        Button(action: { viewModel.toggleFullScreen() }) {
                            Label(viewModel.isFullScreen ? "Exit Full Screen" : "Full Screen", 
                                  systemImage: viewModel.isFullScreen ? "arrow.down.right.and.arrow.up.left" : "arrow.up.left.and.arrow.down.right")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: Binding(
            get: { viewModel.showExportOptions },
            set: { _ in viewModel.hideExportSheet() }
        )) {
            ExportOptionsView(viewModel: viewModel)
        }
    }
    
    // MARK: - Preview Controls
    private var previewControls: some View {
        VStack(spacing: 16) {
            // Device Selection
            HStack {
                Text("Device")
                    .font(.headline)
                
                Spacer()
                
                Picker("Device", selection: Binding(
                    get: { viewModel.selectedDevice },
                    set: { viewModel.selectDevice($0) }
                )) {
                    ForEach(EnhancedPreviewDevice.allCases, id: \.self) { device in
                        HStack {
                            Image(systemName: device.systemImage)
                            Text(device.rawValue)
                        }
                        .tag(device)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // Device Info
            HStack {
                Text("Resolution")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(Int(viewModel.deviceDimensions.width)) × \(Int(viewModel.deviceDimensions.height))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Device Frame Preview
    private func deviceFramePreview(in geometry: GeometryProxy) -> some View {
        let deviceSize = viewModel.deviceDimensions
        let scale = min(
            (geometry.size.width - 40) / deviceSize.width,
            (geometry.size.height - 200) / deviceSize.height
        )
        let scaledSize = CGSize(
            width: deviceSize.width * scale,
            height: deviceSize.height * scale
        )
        
        return VStack {
            Spacer()
            
            ZStack {
                // Device Frame
                RoundedRectangle(cornerRadius: viewModel.selectedDevice == .mobile ? 25 : 15)
                    .fill(Color.black)
                    .frame(width: scaledSize.width + 20, height: scaledSize.height + 20)
                
                // Screen
                RoundedRectangle(cornerRadius: viewModel.selectedDevice == .mobile ? 20 : 10)
                    .fill(Color.white)
                    .frame(width: scaledSize.width, height: scaledSize.height)
                    .overlay(
                        previewContent
                            .scaleEffect(scale)
                            .frame(width: deviceSize.width, height: deviceSize.height)
                            .clipped()
                    )
                    .clipped()
            }
            
            Spacer()
        }
    }
    
    // MARK: - Full Screen Preview
    private var fullScreenPreview: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            previewContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Full Screen Controls Overlay
            VStack {
                HStack {
                    Button(action: { viewModel.toggleFullScreen() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.6))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text(viewModel.selectedDevice.rawValue)
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(15)
                }
                .padding()
                
                Spacer()
            }
        }
    }
    
    // MARK: - Preview Content
    private var previewContent: some View {
        ScrollView {
            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .frame(
                        width: viewModel.deviceDimensions.width,
                        height: max(viewModel.deviceDimensions.height, CGFloat(viewModel.componentCount * 100 + 200))
                    )
                
                ForEach(viewModel.components) { component in
                    InteractivePreviewComponentView(component: component)
                        .position(component.position)
                }
            }
        }
        .frame(width: viewModel.deviceDimensions.width, height: viewModel.deviceDimensions.height)
        .background(Color.white)
        .cornerRadius(viewModel.selectedDevice == .mobile ? 20 : 10)
    }
}

// MARK: - Export Options View
struct ExportOptionsView: View {
    @ObservedObject var viewModel: PreviewViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var htmlContent = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Export Options
                VStack(alignment: .leading, spacing: 16) {
                    Text("Export Options")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    ExportOptionRow(
                        title: "Copy HTML",
                        subtitle: "Copy the generated HTML to clipboard",
                        icon: "doc.on.clipboard",
                        action: copyHTML
                    )
                    
                    ExportOptionRow(
                        title: "Share HTML",
                        subtitle: "Share HTML file via AirDrop, email, etc.",
                        icon: "square.and.arrow.up",
                        action: shareHTML
                    )
                    
                    ExportOptionRow(
                        title: "View HTML Source",
                        subtitle: "View the generated HTML source code",
                        icon: "doc.text",
                        action: viewHTMLSource
                    )
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: [htmlContent])
        }
    }
    
    private func copyHTML() {
        viewModel.copyHTMLToClipboard()
        dismiss()
    }
    
    private func shareHTML() {
        htmlContent = viewModel.shareHTML()
        showingShareSheet = true
    }
    
    private func viewHTMLSource() {
        htmlContent = viewModel.shareHTML()
        UIPasteboard.general.string = htmlContent
        dismiss()
    }
}

// MARK: - Export Option Row
struct ExportOptionRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 30)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}