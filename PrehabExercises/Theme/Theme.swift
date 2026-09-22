import SwiftUI
import UIKit

/// Color palette mirroring the Android app: a beige background with blue (primary)
/// and neutral gray (secondary) accents. Each color adapts between light and dark mode.
enum AppColor {
    static let background = dynamic(light: 0xFBF7EE, dark: 0x201B10)
    static let surface = dynamic(light: 0xFBF7EE, dark: 0x201B10)
    static let surfaceVariant = dynamic(light: 0xEAE0C8, dark: 0x473E28)

    /// True neutral gray (no warm tint) used for exercise cards and image containers.
    static let cardBackground = dynamic(light: 0xF2F2F2, dark: 0x2A2A2A)
    static let imageBackground = dynamic(light: 0xE0E0E0, dark: 0x3D3D3D)

    static let ink = dynamic(light: 0x3A3327, dark: 0xF3ECDA)
    static let inkMuted = dynamic(light: 0x5C5340, dark: 0xD8CBA8)

    static let primary = dynamic(light: 0x1E5FA8, dark: 0x90CAF9)
    static let onPrimary = dynamic(light: 0xFFFFFF, dark: 0x123A66)
    static let primaryContainer = dynamic(light: 0xD3E4FA, dark: 0x1E5FA8)
    static let onPrimaryContainer = dynamic(light: 0x123A66, dark: 0xD3E4FA)

    static let secondaryContainer = dynamic(light: 0xE2E2E2, dark: 0x5A5A5A)
    static let onSecondaryContainer = dynamic(light: 0x3F3F3F, dark: 0xE2E2E2)

    static let error = dynamic(light: 0xB3261E, dark: 0xF2B8B5)

    private static func dynamic(light: UInt32, dark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light)
        })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
