import XCTest
@testable import Levain

final class KefirBatchTests: XCTestCase {
    func testFirstBatchDoesNotRequireSourceBatch() {
        let batch = DomainFixtures.makeKefirBatch(lastManagedAt: .fixedNow)

        XCTAssertNil(batch.sourceBatchId)
        XCTAssertEqual(batch.storageMode, .roomTemperature)
        XCTAssertEqual(batch.expectedRoutineHours, 24)
        XCTAssertEqual(batch.derivedState(at: .fixedNow), .active)
        XCTAssertEqual(batch.primaryActionSuggestion(at: .fixedNow), .manage)
    }

    func testRoomTemperatureTimingMovesThroughWarningAndDueNowStates() {
        let now = Date.fixedNow

        let activeBatch = DomainFixtures.makeKefirBatch(
            storageMode: .roomTemperature,
            lastManagedAt: now.adding(minutes: -(18 * 60))
        )
        XCTAssertEqual(activeBatch.derivedState(at: now), .active)

        let warningBatch = DomainFixtures.makeKefirBatch(
            storageMode: .roomTemperature,
            lastManagedAt: now.adding(minutes: -(21 * 60))
        )
        XCTAssertEqual(warningBatch.derivedState(at: now), .dueSoon)

        let dueNowBatch = DomainFixtures.makeKefirBatch(
            storageMode: .roomTemperature,
            lastManagedAt: now.adding(minutes: -(23 * 60 + 30))
        )
        XCTAssertEqual(dueNowBatch.derivedState(at: now), .dueNow)
        XCTAssertEqual(dueNowBatch.primaryActionSuggestion(at: now), .renew)

        let overdueBatch = DomainFixtures.makeKefirBatch(
            storageMode: .roomTemperature,
            lastManagedAt: now.adding(minutes: -(24 * 60))
        )
        XCTAssertEqual(overdueBatch.derivedState(at: now), .overdue)
        XCTAssertEqual(overdueBatch.primaryActionSuggestion(at: now), .renew)
    }

    func testFridgeBatchStaysPausedUntilItsWarningWindow() {
        let now = Date.fixedNow

        let pausedBatch = DomainFixtures.makeKefirBatch(
            storageMode: .fridge,
            lastManagedAt: now.adding(minutes: -(4 * 24 * 60))
        )
        XCTAssertEqual(pausedBatch.derivedState(at: now), .pausedFridge)

        let warningBatch = DomainFixtures.makeKefirBatch(
            storageMode: .fridge,
            lastManagedAt: now.adding(minutes: -(6 * 24 * 60 + 12 * 60))
        )
        XCTAssertEqual(warningBatch.derivedState(at: now), .dueSoon)

        let dueNowBatch = DomainFixtures.makeKefirBatch(
            storageMode: .fridge,
            lastManagedAt: now.adding(minutes: -(6 * 24 * 60 + 20 * 60))
        )
        XCTAssertEqual(dueNowBatch.derivedState(at: now), .dueNow)

        let overdueBatch = DomainFixtures.makeKefirBatch(
            storageMode: .fridge,
            lastManagedAt: now.adding(minutes: -(7 * 24 * 60))
        )
        XCTAssertEqual(overdueBatch.derivedState(at: now), .overdue)
    }

    func testFreezerBatchWithoutReactivationStaysPaused() {
        let now = Date.fixedNow
        let batch = DomainFixtures.makeKefirBatch(
            storageMode: .freezer,
            lastManagedAt: now.adding(minutes: -(14 * 24 * 60))
        )

        XCTAssertEqual(batch.derivedState(at: now), .pausedFreezer)
        XCTAssertNil(batch.nextManagementAt)
        XCTAssertFalse(batch.supportsAutomaticAlerts)
        XCTAssertEqual(batch.primaryActionSuggestion(at: now), .manage)
    }

    func testFreezerBatchUsesPlannedReactivationForDerivedTiming() {
        let now = Date.fixedNow
        let batch = DomainFixtures.makeKefirBatch(
            storageMode: .freezer,
            lastManagedAt: now.adding(minutes: -(3 * 24 * 60)),
            plannedReactivationAt: now.adding(minutes: 12 * 60)
        )

        XCTAssertEqual(batch.derivedState(at: now), .dueSoon)
        XCTAssertEqual(batch.nextManagementAt, now.adding(minutes: 12 * 60))
        XCTAssertTrue(batch.supportsAutomaticAlerts)
        XCTAssertEqual(batch.primaryActionSuggestion(at: now), .reactivate)
    }

    func testArchivedStateOverridesOperationalTiming() {
        let now = Date.fixedNow
        let batch = DomainFixtures.makeKefirBatch(
            storageMode: .roomTemperature,
            lastManagedAt: now.adding(minutes: -(36 * 60)),
            archivedAt: now.adding(minutes: -30)
        )

        XCTAssertEqual(batch.derivedState(at: now), .archived)
        XCTAssertNil(batch.nextManagementAt)
        XCTAssertFalse(batch.supportsAutomaticAlerts)
        XCTAssertEqual(batch.primaryActionSuggestion(at: now), .open)
    }

    func testDerivedBatchRetainsSourceMetadata() {
        let sourceID = UUID()
        let batch = DomainFixtures.makeKefirBatch(
            lastManagedAt: .fixedNow,
            sourceBatchId: sourceID,
            useLabel: "Backup frigo",
            differentiationNote: "Più denso del batch principale"
        )

        XCTAssertEqual(batch.sourceBatchId, sourceID)
        XCTAssertEqual(batch.useLabel, "Backup frigo")
        XCTAssertEqual(batch.differentiationNote, "Più denso del batch principale")
    }
}
