import SwiftUI

public extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

public extension Color {
    static var softGray: Self { .init(hex: 0xE5E5E5) }
    static var darkGray: Self { .init(hex: 0xAFAFAF) }
    static var softBlack: Self { .init(hex: 0x3C3C3C) }
    static var softGreen: Self { .init(hex: 0xD7FFB8) }
    static var correctGreen: Self { .init(hex: 0x58CC02) }
    static var darkGreen: Self { .init(hex: 0x58A700) }
}
