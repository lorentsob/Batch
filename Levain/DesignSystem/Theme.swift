import SwiftUI

// MARK: - Theme
// Levain Design System — v2.0
// Semantic rule: Green = action/plan · Neutral = past/archived · Red = problem
// Last updated: 2026-03-13

enum Theme {

    // MARK: - Color Palette

    enum Palette {

        // Green scale — brand, actions, active states, planned steps
        static let green25  = Color(hex: "#F2FAF7") // Lightest tint, running card bg tint
        static let green50  = Color(hex: "#E0F4EC") // Running card background
        static let green100 = Color(hex: "#B8E5D0") // Planned badge bg, emphasized borders
        static let green500 = Color(hex: "#1A7D5A") // Primary actions, running badge, tab tint
        static let green600 = Color(hex: "#156349") // Primary dark — pressed states, nav tint
        static let green800 = Color(hex: "#0A3828") // Primary text — headings, body

        // Neutral scale — surfaces, borders, secondary text, archived states
        static let neutral0   = Color(hex: "#FFFFFF") // Card surfaces, pure white
        static let neutral50  = Color(hex: "#F7F8F7") // App background
        static let neutral100 = Color(hex: "#EDEEED") // Done badge bg, subtle surfaces
        static let neutral200 = Color(hex: "#DCDEDC") // Default borders, done timeline dot
        static let neutral400 = Color(hex: "#9CA09E") // Disabled/decorative only — do NOT use for readable text
        static let neutral500 = Color(hex: "#737876") // Secondary text — metadata, descriptions
        static let neutral600 = Color(hex: "#4A4E4C") // Tertiary text — labels, timestamps, overlines (WCAG AA: 7.2:1)

        // Error scale — problems, overdue, destructive actions
        static let error      = Color(hex: "#E53E3E") // Error foreground, danger CTA bg
        static let errorDark  = Color(hex: "#9B1C1C") // Error text on light backgrounds (WCAG AA)
        static let errorLight = Color(hex: "#FEE2E2") // Overdue/danger card bg
        static let errorBorder = Color(hex: "#FECACA") // Overdue card border

        // Warning / amber scale — attention required, not yet a problem
        static let amber100  = Color(hex: "#FEF3C7") // Warning badge background
        static let amber800  = Color(hex: "#92400E") // Warning text on amber100 (WCAG AA)
        static let amberBorder = Color(hex: "#FDE68A") // Warning badge border
    }

    // MARK: - Semantic Text Tokens

    enum Text {
        /// Primary body text and headings — green800 (#0A3828), contrast 13:1
        static let primary        = Palette.green800
        /// Secondary text — metadata, descriptions — neutral500 (#737876), contrast 4.6:1
        static let secondary      = Palette.neutral500
        /// Tertiary text — labels, timestamps, overlines — neutral600 (#4A4E4C), contrast 7.2:1
        /// NOTE: was neutral400 in v1.0 — updated for WCAG AA compliance
        static let tertiary       = Palette.neutral600
        /// Text on solid green backgrounds (buttons, running badge)
        static let onPrimary      = Palette.neutral0
        /// Text on error/danger backgrounds
        static let onDanger       = Palette.errorDark
        /// Subdued text on green header surfaces
        static let onHeaderSubtle = Palette.neutral0.opacity(0.65)
        /// Disabled / placeholder text — neutral400 only for non-interactive elements
        static let disabled       = Palette.neutral400
    }

    // MARK: - Semantic Surface Tokens

    enum Surface {
        /// Main app background — neutral50
        static let app        = Palette.neutral50
        /// Card backgrounds — white
        static let card       = Palette.neutral0
        /// Subtle secondary surfaces — neutral100
        static let subtle     = Palette.neutral100
        /// Tinted surface — green25, used for running card bg tint
        static let tinted     = Palette.green25
        /// Running step card background — green50
        static let running    = Palette.green50
        /// Planned step card background — white (badge carries the green signal)
        static let planned    = Palette.neutral0
        /// Done/archived card background — neutral50 @ 60% opacity
        static let done       = Palette.neutral50
        /// Overdue / danger card background — errorLight
        static let danger     = Palette.errorLight
        /// Header bar background — green500
        static let header     = Palette.green500
    }

    // MARK: - Semantic Border Tokens

    enum Border {
        /// Default card and surface borders — neutral200
        static let defaultColor = Palette.neutral200
        /// Emphasized green border — green100, used on planned/tinted cards
        static let emphasis     = Palette.green100
        /// Active / focused state — green500
        static let active       = Palette.green500
        /// Danger / overdue border — errorBorder
        static let danger       = Palette.errorBorder
        /// Done card border — neutral200 @ 60%
        static let done         = Palette.neutral200.opacity(0.6)
    }

    // MARK: - Status Badge Tokens
    // Semantic rule: GREEN = active now or planned · GRAY = past/archived · AMBER = warning · RED = problem
    //
    // .running  → green filled    — happening now
    // .pending  → green tinted    — in the plan, coming up
    // .done     → neutral gray    — archived, no action needed
    // .skipped  → neutral gray    — archived, dimmed
    // .warning  → amber tinted    — attenzione richiesta, non ancora un problema
    // .overdue  → red tinted      — problem, requires attention
    // .danger   → red filled/tinted — critical

    enum Status {

        // Running — solid green, maximum weight
        static let runningBackground  = Palette.green500
        static let runningForeground  = Palette.neutral0

        // Pending / Planned — light green, still part of the plan
        static let pendingBackground  = Palette.green100
        static let pendingForeground  = Palette.green800

        // Done — neutral gray, archived / past
        // Deliberately NOT green — communicates "over", not "success"
        static let doneBackground     = Palette.neutral100
        static let doneForeground     = Palette.neutral600

        // Skipped — same neutral family as done, slightly dimmer
        static let skippedBackground  = Palette.neutral100
        static let skippedForeground  = Palette.neutral500

        // Overdue — red, problem requiring action
        static let overdueBackground  = Palette.errorLight
        static let overdueForeground  = Palette.errorDark

        // Danger — same red family as overdue
        static let dangerBackground   = Palette.errorLight
        static let dangerForeground   = Palette.errorDark

        // Legacy warning state — keep it in the green family to respect v2 semantic rules:
        // green = action/plan, red = problem, gray = archived.
        static let warningBackground  = Palette.green100
        static let warningForeground  = Palette.green800
        static let warningBorder      = Palette.green100

        // Info — lightest green tint, informational only
        static let infoBackground     = Palette.green25
        static let infoForeground     = Palette.green600

        // Count / metric badges — light green
        static let countBackground    = Palette.green50
        static let countForeground    = Palette.green800
    }

    // MARK: - Control / Button Tokens

    enum Control {
        // Primary button — solid green, all main CTAs (Avvia, Completa, Rinfresca, Salva)
        static let primaryFill        = Palette.green500
        static let primaryForeground  = Palette.neutral0

        // Secondary button — outline green, secondary CTAs on non-danger cards
        // Background: transparent · Border: green500 · Text: green800
        // NOTE: v1.0 used neutral100 bg — updated to outline style for semantic clarity
        static let secondaryFill      = Color.clear
        static let secondaryForeground = Palette.green800
        static let secondaryBorder    = Palette.green500

        // Danger button — red fill, destructive actions (Annulla impasto, Elimina)
        // Also used as primary CTA on overdue cards (Avvia ora, Rinfresca subito)
        static let dangerFill         = Palette.error
        static let dangerForeground   = Palette.neutral0

        // Tab bar
        static let tabActiveTint      = Palette.green500
        static let tabBackground      = Palette.neutral0
    }

    // MARK: - Timeline Dot Tokens

    enum TimelineDot {
        /// Done step dot — neutral200, flat, communicates "past"
        static let done    = Palette.neutral200
        /// Running step dot — green500 with green50 ring (use .overlay ring separately)
        static let running = Palette.green500
        /// Running dot ring color
        static let runningRing = Palette.green50
        /// Planned step dot — green100 with green500 border
        static let pending = Palette.green100
        /// Planned dot border
        static let pendingBorder = Palette.green500.opacity(0.4)
        /// Overdue step dot — error red
        static let overdue = Palette.error
        /// Skipped step dot — neutral200, same as done
        static let skipped = Palette.neutral200
    }

    // MARK: - Typography

    enum Typography {
        static let largeTitle           = Font.system(size: 34, weight: .regular)
        static let title1               = Font.system(size: 28, weight: .bold)
        static let title2               = Font.system(size: 22, weight: .bold)
        static let title3               = Font.system(size: 20, weight: .semibold)
        static let headline             = Font.system(size: 17, weight: .semibold)
        static let subheadline          = Font.system(size: 15, weight: .regular)
        static let subheadlineSemibold  = Font.system(size: 15, weight: .semibold)
        static let body                 = Font.system(size: 17, weight: .regular)
        static let footnote             = Font.system(size: 13, weight: .regular)
        static let footnoteSemibold     = Font.system(size: 13, weight: .semibold)
        static let caption1             = Font.system(size: 12, weight: .regular)
        static let caption1Semibold     = Font.system(size: 12, weight: .semibold)
        static let caption2             = Font.system(size: 11, weight: .regular)
        static let overline             = Font.system(size: 11, weight: .semibold)
    }

    // MARK: - Spacing

    enum Spacing {
        static let xxs:   CGFloat = 4
        static let xs:    CGFloat = 8
        static let sm:    CGFloat = 8
        static let md:    CGFloat = 16
        static let lg:    CGFloat = 24
        static let xl:    CGFloat = 32
        static let xxl:   CGFloat = 48
        static let xxxl:  CGFloat = 64
    }

    // MARK: - Screen Layout

    enum Layout {
        static let screenHorizontalInset = Spacing.md
        static let screenTopInset = Spacing.sm
        static let screenBottomInset = Spacing.xxxl
        static let sectionGap = Spacing.lg
        static let rowGap = Spacing.sm
    }

    // MARK: - Radius (all .continuous / squircle)

    enum Radius {
        static let card:       CGFloat = 28
        static let nestedCard: CGFloat = 22
        static let control:    CGFloat = 18
        static let compact:    CGFloat = 16
        static let full:       CGFloat = 9999
    }

    // MARK: - Shadow

    enum Shadow {
        /// Standard card shadow — green800 @ 6%
        static let card    = Palette.green800.opacity(0.06)
        /// Running card shadow — green500 @ 12%
        static let primary = Palette.green500.opacity(0.12)
        /// Danger card shadow — error @ 10%
        static let danger  = Palette.error.opacity(0.10)
    }

    // MARK: - Animation

    enum Animation {
        static let micro:   SwiftUI.Animation = .easeOut(duration: 0.15)
        static let standard: SwiftUI.Animation = .spring(response: 0.35, dampingFraction: 0.75)
        static let gentle:   SwiftUI.Animation = .spring(response: 0.5,  dampingFraction: 0.8)
    }

    // MARK: - Backward Compatibility Aliases (v1.0 → v2.0)
    // Preserve compilation of existing feature views while migration is in progress.

    static let background = Surface.app
    static let panel      = Surface.card
    static let accent     = Control.primaryFill
    static let accentSoft = Surface.subtle
    static let ink        = Text.primary
    static let muted      = Text.secondary
}

struct ScreenTitleBlock: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
            Text(title)
                .font(Theme.Typography.title1)
                .foregroundStyle(Theme.Text.primary)
            Text(subtitle)
                .font(Theme.Typography.subheadline)
                .foregroundStyle(Theme.Text.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct SectionTitleLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(Theme.Typography.headline)
            .foregroundStyle(Theme.Text.primary)
    }
}

// MARK: - View Modifiers

extension View {
    func levainScrollScreenPadding() -> some View {
        self
            .padding(.horizontal, Theme.Layout.screenHorizontalInset)
            .padding(.top, Theme.Layout.screenTopInset)
            .padding(.bottom, Theme.Layout.screenBottomInset)
    }

    func levainListSurface() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(Theme.Surface.app.ignoresSafeArea())
    }

    /// Squircle clip with continuous corner style
    func squircle(radius: CGFloat = Theme.Radius.card) -> some View {
        self.clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    /// Squircle stroke overlay
    func squircleBorder(_ color: Color, width: CGFloat = 0.5, radius: CGFloat = Theme.Radius.card) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(color, lineWidth: width)
        )
    }

    /// Standard card shadow
    func cardShadow(color: Color = Theme.Shadow.card) -> some View {
        self.shadow(color: color, radius: 18, x: 0, y: 8)
    }

    /// Running card shadow (green tint)
    func primaryShadow() -> some View {
        self.shadow(color: Theme.Shadow.primary, radius: 18, x: 0, y: 8)
    }

    /// Danger card shadow (red tint)
    func dangerShadow() -> some View {
        self.shadow(color: Theme.Shadow.danger, radius: 18, x: 0, y: 8)
    }
}

extension EdgeInsets {
    static func levainListRow(
        top: CGFloat = 0,
        bottom: CGFloat = Theme.Spacing.sm
    ) -> EdgeInsets {
        EdgeInsets(
            top: top,
            leading: Theme.Layout.screenHorizontalInset,
            bottom: bottom,
            trailing: Theme.Layout.screenHorizontalInset
        )
    }
}

// MARK: - Color Hex Init

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8)  & 0xFF) / 255
        let b = Double(int & 0xFF)         / 255
        self.init(red: r, green: g, blue: b)
    }
}
