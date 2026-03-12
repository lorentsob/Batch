import SwiftUI

enum Theme {
    enum Palette {
        static let green25 = Color(hex: 0xF2FAF7)
        static let green50 = Color(hex: 0xE0F4EC)
        static let green100 = Color(hex: 0xB8E5D0)
        static let green500 = Color(hex: 0x1A7D5A)
        static let green600 = Color(hex: 0x156349)
        static let green800 = Color(hex: 0x0A3828)

        static let neutral0 = Color(hex: 0xFFFFFF)
        static let neutral50 = Color(hex: 0xF7F8F7)
        static let neutral100 = Color(hex: 0xEDEEED)
        static let neutral200 = Color(hex: 0xDCDEDD)
        static let neutral400 = Color(hex: 0x9CA09E)
        static let neutral500 = Color(hex: 0x737876)

        static let error = Color(hex: 0xE53E3E)
        static let errorLight = Color(hex: 0xFEE2E2)
    }

    enum Surface {
        static let app = Palette.neutral50
        static let card = Palette.neutral0
        static let subtle = Palette.neutral100
        static let tinted = Palette.green25
        static let header = Palette.green500
        static let dangerTint = Palette.errorLight
    }

    enum Text {
        static let primary = Palette.green800
        static let secondary = Palette.neutral500
        static let tertiary = Palette.neutral400
        static let onPrimary = Palette.neutral0
        static let onHeaderSubtle = Palette.neutral0.opacity(0.65)
    }

    enum Border {
        static let defaultColor = Palette.neutral200
        static let emphasis = Palette.green100
        static let active = Palette.green500
        static let danger = Palette.error
    }

    enum Status {
        static let runningBackground = Palette.green500
        static let runningForeground = Palette.neutral0

        static let doneBackground = Palette.green50
        static let doneForeground = Palette.green600

        static let pendingBackground = Palette.neutral100
        static let pendingForeground = Palette.neutral400

        static let infoBackground = Palette.green25
        static let infoForeground = Palette.green600

        static let countBackground = Palette.green50
        static let countForeground = Palette.green800

        static let scheduleBackground = Palette.neutral100
        static let scheduleForeground = Palette.neutral500

        static let dangerBackground = Palette.errorLight
        static let dangerForeground = Palette.error
    }

    enum Control {
        static let primaryFill = Palette.green500
        static let primaryForeground = Palette.neutral0

        static let secondaryFill = Palette.neutral100
        static let secondaryForeground = Palette.green800

        static let outlineBorder = Palette.neutral200

        static let ghostForeground = Palette.green600

        static let dangerFill = Palette.errorLight
        static let dangerForeground = Palette.error

        static let tabActiveTint = Palette.green500
        static let tabBackground = Palette.neutral0
    }

    enum Radius {
        static let card: CGFloat = 28
        static let nestedCard: CGFloat = 22
        static let control: CGFloat = 18
        static let compact: CGFloat = 16
    }

    enum Shadow {
        static let card = Text.primary.opacity(0.06)
    }

    static let background = Surface.app
    static let panel = Surface.card
    static let accent = Control.primaryFill
    static let accentSoft = Surface.subtle
    static let ink = Text.primary
    static let muted = Text.secondary
    static let success = Status.doneForeground
    static let warning = Status.runningBackground
    static let danger = Status.dangerForeground
}

private extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
