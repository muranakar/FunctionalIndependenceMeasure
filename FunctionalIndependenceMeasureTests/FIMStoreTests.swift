//
//  FIMStoreTests.swift
//  FunctionalIndependenceMeasureTests
//
//  SwiftData上での削除の連鎖と、編集後の集計を確認する。
//

import XCTest
import SwiftData
@testable import FunctionalIndependenceMeasure

final class FIMStoreTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUpWithError() throws {
        // ディスクを汚さないようメモリ上のストアで検証する
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(
            for: Assessor.self, TargetPerson.self, FIMRecord.self,
            configurations: configuration
        )
        context = ModelContext(container)
    }

    override func tearDownWithError() throws {
        container = nil
        context = nil
    }

    func testDeletingAssessorRemovesTargetPersonsAndRecords() throws {
        _ = try makeStoredRecord()
        XCTAssertEqual(try context.fetch(FetchDescriptor<TargetPerson>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<FIMRecord>()).count, 1)

        let assessor = try XCTUnwrap(try context.fetch(FetchDescriptor<Assessor>()).first)
        context.delete(assessor)
        try context.save()

        XCTAssertEqual(
            try context.fetch(FetchDescriptor<TargetPerson>()).count, 0,
            "評価者を削除しても対象者が残っている"
        )
        XCTAssertEqual(
            try context.fetch(FetchDescriptor<FIMRecord>()).count, 0,
            "評価者を削除しても評価結果が残っている"
        )
    }

    func testDeletingRecordKeepsTargetPerson() throws {
        let record = try makeStoredRecord()
        context.delete(record)
        try context.save()

        XCTAssertEqual(try context.fetch(FetchDescriptor<FIMRecord>()).count, 0)
        XCTAssertEqual(
            try context.fetch(FetchDescriptor<TargetPerson>()).count, 1,
            "評価を消しただけで対象者まで消えている"
        )
    }

    /// 編集画面と同じ手順で書き換えたとき、集計が追従すること
    func testEditingScoresUpdatesTotals() throws {
        let record = try makeStoredRecord()
        XCTAssertEqual(record.total, 74)

        for item in FIMItem.allCases {
            record[item] = FIMScore.max
        }
        record.updatedAt = Date(timeIntervalSince1970: 1_800_000_000)
        try context.save()

        XCTAssertEqual(record.total, 126)
        XCTAssertEqual(record.motorSubtotal, 91)
        XCTAssertEqual(record.cognitionSubtotal, 35)
        XCTAssertFalse(record.hasUnansweredItem, "全項目入力したのに未入力扱いが残っている")
        XCTAssertNotNil(record.updatedAt)
    }

    /// 対象者を絞り込む述語が、一覧画面と同じ条件で正しく動くこと
    func testFetchingRecordsByTargetPerson() throws {
        let record = try makeStoredRecord()
        let targetPersonID = try XCTUnwrap(record.targetPerson?.uuidString)

        // 別の対象者にも評価を作る
        let otherTargetPerson = TargetPerson(name: "別の対象者")
        context.insert(otherTargetPerson)
        let otherRecord = FIMRecord(scores: Array(repeating: 1, count: 18))
        context.insert(otherRecord)
        otherRecord.targetPerson = otherTargetPerson
        try context.save()

        let descriptor = FetchDescriptor<FIMRecord>(
            predicate: #Predicate { $0.targetPerson?.uuidString == targetPersonID }
        )
        let fetched = try context.fetch(descriptor)
        XCTAssertEqual(fetched.count, 1, "対象者で絞り込めていない")
        XCTAssertEqual(fetched.first?.total, 74)
    }

    // MARK: - 補助

    @discardableResult
    private func makeStoredRecord() throws -> FIMRecord {
        let assessor = Assessor(name: "テスト評価者")
        context.insert(assessor)

        let targetPerson = TargetPerson(name: "テスト対象者")
        context.insert(targetPerson)
        targetPerson.assessor = assessor

        let record = FIMRecord(scores: [7, 6, 5, 4, 3, 2, 0, 1, 7, 6, 5, 4, 3, 2, 1, 7, 6, 5])
        context.insert(record)
        record.targetPerson = targetPerson

        try context.save()
        return record
    }
}
