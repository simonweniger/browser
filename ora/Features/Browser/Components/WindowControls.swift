import AppKit
import SwiftUI

enum WindowControlType {
    case close, minimize, zoom
}

struct WindowControls: View {
    @State private var isHovered = false
    let isFullscreen: Bool

    var body: some View {
        if !isFullscreen {
            HStack(spacing: 9) {
                WindowControlButton(type: .close, isHovered: $isHovered)
                WindowControlButton(type: .minimize, isHovered: $isHovered)
                WindowControlButton(type: .zoom, isHovered: $isHovered)
            }
            .padding(.horizontal, 18)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isHovered = hovering
                }
            }
        } else {
            EmptyView()
        }
    }
}

struct WindowControlButton: View {
    @Environment(\.window) private var window

    let type: WindowControlType
    @Binding var isHovered: Bool
    @State private var isWindowFocused = true

    private var buttonSize: CGFloat {
        if #available(macOS 26.0, *) {
            return 14
        } else {
            return 12
        }
    }

    private var assetBaseName: String {
        switch type {
        case .close: return "close"
        case .minimize: return "minimize"
        case .zoom: return "maximize"
        }
    }

    private var imageName: String {
        guard isWindowFocused else { return "no-focus" }
        return isHovered ? "\(assetBaseName)-hover" : "\(assetBaseName)-normal"
    }

    private var imageOpacity: Double {
        isWindowFocused ? 1.0 : 0.25
    }

    var body: some View {
        Image(imageName)
            .resizable()
            .frame(width: buttonSize, height: buttonSize)
            .opacity(imageOpacity)
            .onAppear {
                syncWindowFocus()
            }
            .onChange(of: window) { _, _ in
                syncWindowFocus()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification)) { notification in
                guard notification.object as? NSWindow === window else { return }
                isWindowFocused = true
            }
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didResignKeyNotification)) { notification in
                guard notification.object as? NSWindow === window else { return }
                isWindowFocused = false
            }
            .onTapGesture {
                performAction()
            }
    }

    private func performAction() {
        guard let window else { return }
        switch type {
        case .close:
            window.performClose(nil)
        case .minimize:
            window.performMiniaturize(nil)
        case .zoom:
            window.toggleFullScreen(nil)
        }
    }

    private func syncWindowFocus() {
        isWindowFocused = window?.isKeyWindow ?? false
    }
}
