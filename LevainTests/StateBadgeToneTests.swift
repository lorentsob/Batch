import XCTest
@testable import Levain

final class StateBadgeToneTests: XCTestCase {
    func testStepStatusUsesSemanticToneMapping() {
        XCTAssertEqual(StateBadge(stepStatus: .pending).tone, .pending)
        XCTAssertEqual(StateBadge(stepStatus: .running).tone, .running)
        XCTAssertEqual(StateBadge(stepStatus: .done).tone, .done)
        XCTAssertEqual(StateBadge(stepStatus: .skipped).tone, .pending)
    }

    func testBakeStatusUsesSemanticToneMapping() {
        XCTAssertEqual(StateBadge(bakeStatus: .planned).tone, .pending)
        XCTAssertEqual(StateBadge(bakeStatus: .inProgress).tone, .running)
        XCTAssertEqual(StateBadge(bakeStatus: .completed).tone, .done)
        XCTAssertEqual(StateBadge(bakeStatus: .cancelled).tone, .danger)
    }

    func testStarterDueStateUsesSemanticToneMapping() {
        XCTAssertEqual(StateBadge(dueState: .ok).tone, .done)
        XCTAssertEqual(StateBadge(dueState: .dueToday).tone, .schedule)
        XCTAssertEqual(StateBadge(dueState: .overdue).tone, .danger)
    }

    func testSemanticTonesKeepStableTokens() {
        XCTAssertEqual(StateBadge.Tone.running.backgroundToken, "green-500")
        XCTAssertEqual(StateBadge.Tone.running.foregroundToken, "neutral-0")
        XCTAssertEqual(StateBadge.Tone.done.backgroundToken, "green-50")
        XCTAssertEqual(StateBadge.Tone.pending.backgroundToken, "neutral-100")
        XCTAssertEqual(StateBadge.Tone.schedule.foregroundToken, "neutral-500")
        XCTAssertEqual(StateBadge.Tone.danger.backgroundToken, "error-light")
    }
}
