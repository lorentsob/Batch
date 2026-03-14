import XCTest
@testable import Levain

@MainActor
final class StateBadgeToneTests: XCTestCase {
    func testStepStatusUsesSemanticToneMapping() {
        XCTAssertEqual(StateBadge(stepStatus: .pending).tone, .pending)
        XCTAssertEqual(StateBadge(stepStatus: .running).tone, .running)
        XCTAssertEqual(StateBadge(stepStatus: .done).tone, .done)
        XCTAssertEqual(StateBadge(stepStatus: .skipped).tone, .skipped)
    }

    func testBakeStatusUsesSemanticToneMapping() {
        XCTAssertEqual(StateBadge(bakeStatus: .planned).tone, .info)
        XCTAssertEqual(StateBadge(bakeStatus: .inProgress).tone, .running)
        XCTAssertEqual(StateBadge(bakeStatus: .completed).tone, .done)
        XCTAssertEqual(StateBadge(bakeStatus: .cancelled).tone, .danger)
    }

    func testStarterDueStateUsesSemanticToneMapping() {
        XCTAssertEqual(StateBadge(dueState: .ok).tone, .done)
        XCTAssertEqual(StateBadge(dueState: .dueToday).tone, .pending)
        XCTAssertEqual(StateBadge(dueState: .overdue).tone, .overdue)
    }

    func testScheduleToneRemainsExplicitAlias() {
        XCTAssertEqual(StateBadge.Tone.schedule.rawValue, "schedule")
        XCTAssertNotEqual(StateBadge.Tone.schedule, .info)
    }
}
