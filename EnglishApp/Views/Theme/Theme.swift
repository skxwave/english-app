import SwiftUI

enum AppTheme: String, CaseIterable {
    case system, light, dark

    var label: String { rawValue.capitalized }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

enum Theme {
    static let background = Color(light: 0xF9F8F6, dark: 0x352F44)
    static let card = Color(light: 0xEFE9E3, dark: 0x5C5470)
    static let accent = Color(light: 0xD9CFC7, dark: 0xB9B4C7)
    static let highlight = Color(light: 0xC9B59C, dark: 0xFAF0E6)
}

extension Color {
    init(light: UInt32, dark: UInt32) {
        self.init(UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light) })
    }
}

private extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}

extension View {
    func themedScreen() -> some View {
        scrollContentBackground(.hidden).background(Theme.background.ignoresSafeArea())
    }
}
