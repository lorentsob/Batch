import SwiftUI

struct TodayStepCardView: View {
    let bake: Bake
    let step: BakeStep
    let urgency: TodayAgendaItem.Urgency
    let onPrimaryAction: () -> Void
    let onOpenDetail: () -> Void
    let onOpenShift: () -> Void
    let onQuickShift: (Int) -> Void

    var body: some View {
        ActiveStepHeroCard(
            contextLabel: urgencyLabel,
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

    private var urgencyLabel: String {
        switch urgency {
        case .overdue: return "In ritardo"
        case .warning: return "Da fare"
        case .active:  return "Oggi"
        case .preview: return "Domani"
        }
    }
}
