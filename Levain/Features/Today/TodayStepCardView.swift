import SwiftUI

struct TodayStepCardView: View {
    let bake: Bake
    let step: BakeStep
    let section: TodayAgendaItem.Section
    let onPrimaryAction: () -> Void
    let onOpenDetail: () -> Void
    let onOpenShift: () -> Void
    let onQuickShift: (Int) -> Void

    var body: some View {
        ActiveStepHeroCard(
            contextLabel: sectionLabel,
            contextValue: bake.name,
            step: step,
            onPrimaryAction: onPrimaryAction,
            onDetail: onOpenDetail,
            onCustomShift: allowsShift ? onOpenShift : nil,
            onQuickShift: allowsShift ? onQuickShift : nil
        )
        .accessibilityIdentifier("TodayOperationalCard")
    }

    private var allowsShift: Bool {
        step.status == .running || step.isOverdue()
    }

    private var sectionLabel: String {
        switch section {
        case .urgent:
            return "Da fare"
        case .scheduled:
            return "Oggi"
        case .tomorrow:
            return "Domani"
        }
    }
}
