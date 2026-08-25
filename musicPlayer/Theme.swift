//
//  Theme.swift
//  musicPlayer
//

import SwiftUI

// MARK: - Color Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - App Theme Colors & Gradients
struct AppTheme {
    // Primary Backgrounds
    static let backgroundDark = Color(hex: "#090B10")
    static let backgroundSecondary = Color(hex: "#11151F")
    static let cardBackground = Color(hex: "#181E2B").opacity(0.85)
    static let glassBackground = Color(hex: "#1E2536").opacity(0.65)
    
    // Accent Colors
    static let primaryAccent = Color(hex: "#6366F1")    // Indigo
    static let secondaryAccent = Color(hex: "#EC4899")  // Pink
    static let cyanAccent = Color(hex: "#06B6D4")       // Electric Cyan
    static let emeraldAccent = Color(hex: "#10B981")    // Emerald Green
    static let amberAccent = Color(hex: "#F59E0B")      // Amber Gold
    static let purpleAccent = Color(hex: "#8B5CF6")     // Royal Purple
    
    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "#6366F1"), Color(hex: "#EC4899")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let neonCyanGradient = LinearGradient(
        colors: [Color(hex: "#06B6D4"), Color(hex: "#3B82F6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let sunsetGradient = LinearGradient(
        colors: [Color(hex: "#F43F5E"), Color(hex: "#FB923C")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let emeraldGradient = LinearGradient(
        colors: [Color(hex: "#10B981"), Color(hex: "#06B6D4")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let purpleNightGradient = LinearGradient(
        colors: [Color(hex: "#8B5CF6"), Color(hex: "#D946EF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let darkGlassGradient = LinearGradient(
        colors: [Color(hex: "#222A3E").opacity(0.7), Color(hex: "#121724").opacity(0.85)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// MARK: - Glassmorphic Card View Modifier
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var strokeColor: Color = Color.white.opacity(0.12)
    
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppTheme.glassBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(strokeColor, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 6)
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20, strokeColor: Color = Color.white.opacity(0.12)) -> some View {
        self.modifier(GlassCardModifier(cornerRadius: cornerRadius, strokeColor: strokeColor))
    }
    
    func glowingShadow(color: Color = AppTheme.primaryAccent, radius: CGFloat = 12) -> some View {
        self.shadow(color: color.opacity(0.45), radius: radius, x: 0, y: 4)
    }
}

// MARK: - Haptic Feedback Utility
struct HapticManager {
    static let shared = HapticManager()
    private init() {}
    
    func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }
    
    func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
