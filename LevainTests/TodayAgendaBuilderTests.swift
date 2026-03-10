import Testing
import Foundation
@testable import Levain

@Suite("Today Agenda Builder")
struct TodayAgendaBuilderTests {
    
    @Test("Agenda groups steps into correct priority sections")
    func testAgendaSectionGrouping() {
        // Given
        let now = Date(timeIntervalSince1970: 1_000_000)
        let bake = DomainFixtures.makeBake(target: now.addingTimeInterval(3600 * 24))
        
        // Add a step that is running
        let runningStep = BakeStep(orderIndex: 0, type: .autolysis, nameOverride: "Running", plannedStart: now.addingTimeInterval(-3600), plannedDurationMinutes: 120)
        runningStep.status = .running
        runningStep.bake = bake
        
        // Add a step that is overdue (pending but end time passed)
        let overdueStep = BakeStep(orderIndex: 1, type: .mix, nameOverride: "Overdue", plannedStart: now.addingTimeInterval(-7200), plannedDurationMinutes: 60)
        overdueStep.status = .pending
        overdueStep.bake = bake
        
        // Add an upcoming step (planned for later today)
        let upcomingStep = BakeStep(orderIndex: 2, type: .bulk, nameOverride: "Upcoming", plannedStart: now.addingTimeInterval(3600), plannedDurationMinutes: 30)
        upcomingStep.bake = bake
        
        // Add a later step (planned for tomorrow)
        let laterStep = BakeStep(orderIndex: 3, type: .shape, nameOverride: "Later", plannedStart: now.addingTimeInterval(3600 * 25), plannedDurationMinutes: 30)
        laterStep.bake = bake
        
        bake.steps = [runningStep, overdueStep, upcomingStep, laterStep]
        
        // Add a due starter
        let starter = DomainFixtures.makeStarter(name: "Starter", refreshIntervalDays: 7, lastRefresh: now.addingTimeInterval(-3600 * 24 * 7))
        
        // When
        let agenda = TodayAgendaBuilder.build(bakes: [bake], starters: [starter], now: now)
        
        // Then
        #expect(agenda[.now]?.count == 2)
        #expect(agenda[.now]?.contains(where: { $0.title.contains("Running") }) == true)
        #expect(agenda[.now]?.contains(where: { $0.title.contains("Overdue") }) == true)
        
        #expect(agenda[.upcoming]?.count == 1)
        #expect(agenda[.upcoming]?.first?.title.contains("Upcoming") == true)
        
        #expect(agenda[.starter]?.count == 1)
        #expect(agenda[.starter]?.first?.title.contains("Starter") == true)
        
        #expect(agenda[.later]?.count == 1)
        #expect(agenda[.later]?.first?.title.contains("Later") == true)
    }
    
    @Test("Agenda sorts items by date within sections")
    func testAgendaSorting() {
        let now = Date(timeIntervalSince1970: 1_000_000)
        let bake = DomainFixtures.makeBake(target: now.addingTimeInterval(3600 * 24))
        
        let step1 = BakeStep(orderIndex: 0, type: .mix, nameOverride: "First", plannedStart: now.addingTimeInterval(3600), plannedDurationMinutes: 30)
        let step2 = BakeStep(orderIndex: 1, type: .bulk, nameOverride: "Second", plannedStart: now.addingTimeInterval(1800), plannedDurationMinutes: 30)
        
        bake.steps = [step1, step2]
        
        let agenda = TodayAgendaBuilder.build(bakes: [bake], starters: [], now: now)
        
        #expect(agenda[.upcoming]?.count == 2)
        #expect(agenda[.upcoming]?[0].title.contains("Second") == true)
        #expect(agenda[.upcoming]?[1].title.contains("First") == true)
    }
    
    @Test("Agenda excludes terminal steps")
    func testAgendaExcludesTerminal() {
        let now = Date(timeIntervalSince1970: 1_000_000)
        let bake = DomainFixtures.makeBake(target: now.addingTimeInterval(3600 * 24))
        
        let stepDone = BakeStep(orderIndex: 0, type: .mix, nameOverride: "Done", plannedStart: now.addingTimeInterval(-3600), plannedDurationMinutes: 30)
        stepDone.status = .done
        stepDone.bake = bake
        
        let stepSkipped = BakeStep(orderIndex: 1, type: .bulk, nameOverride: "Skipped", plannedStart: now.addingTimeInterval(-1800), plannedDurationMinutes: 30)
        stepSkipped.status = .skipped
        stepSkipped.bake = bake
        
        bake.steps = [stepDone, stepSkipped]
        
        let agenda = TodayAgendaBuilder.build(bakes: [bake], starters: [], now: now)
        
        #expect(agenda.values.allSatisfy { $0.isEmpty })
    }
}
