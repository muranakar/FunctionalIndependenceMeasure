//
//  ReviewCounterTests.swift
//  FunctionalIndependenceMeasureTests
//
//  評価依頼の条件（節目の回数・120 日・版ごと 1 回）を確認する。
//

import XCTest
@testable import FunctionalIndependenceMeasure

final class ReviewCounterTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 1_800_000_000)

    func testOnlyMilestoneCounts() {
        XCTAssertFalse(ReviewCounter.shouldRequest(count: 9, lastAsk: nil, lastVersion: nil, currentVersion: "1.6.4", now: now))
        XCTAssertTrue(ReviewCounter.shouldRequest(count: 10, lastAsk: nil, lastVersion: nil, currentVersion: "1.6.4", now: now))
        XCTAssertFalse(ReviewCounter.shouldRequest(count: 11, lastAsk: nil, lastVersion: nil, currentVersion: "1.6.4", now: now))
    }

    func testIntervalAndOncePerVersion() {
        let longAgo = now.addingTimeInterval(-200 * 86_400)
        let recent = now.addingTimeInterval(-30 * 86_400)
        XCTAssertFalse(ReviewCounter.shouldRequest(count: 31, lastAsk: longAgo, lastVersion: "1.6.4", currentVersion: "1.6.4", now: now))
        XCTAssertFalse(ReviewCounter.shouldRequest(count: 31, lastAsk: recent, lastVersion: "1.6.3", currentVersion: "1.6.4", now: now))
        XCTAssertTrue(ReviewCounter.shouldRequest(count: 31, lastAsk: longAgo, lastVersion: "1.6.3", currentVersion: "1.6.4", now: now))
    }

    func testPendingRequestIsConsumedOnce() {
        XCTAssertFalse(ReviewCounter.consumePendingRequest())
        ReviewCounter.schedulePendingRequest()
        XCTAssertTrue(ReviewCounter.consumePendingRequest())
        XCTAssertFalse(ReviewCounter.consumePendingRequest())
    }
}
