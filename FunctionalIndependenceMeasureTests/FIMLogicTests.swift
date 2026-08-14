//
//  FIMLogicTests.swift
//  FunctionalIndependenceMeasureTests
//
//  集計・コピー文字列・PDF出力が、旧バージョンと同じ結果になることを確認する。
//

import XCTest
import PDFKit
@testable import FunctionalIndependenceMeasure

final class FIMLogicTests: XCTestCase {

    /// 18項目に 1..7 を循環で入れた評価。7番目（排尿管理）だけ未入力にしてある
    private func makeRecord() -> FIMRecord {
        let record = FIMRecord(createdAt: Date(timeIntervalSince1970: 1_700_000_000))
        let scores = [7, 6, 5, 4, 3, 2, 0, 1, 7, 6, 5, 4, 3, 2, 1, 7, 6, 5]
        for (index, item) in FIMItem.allCases.enumerated() {
            record[item] = scores[index]
        }
        return record
    }

    // MARK: - 項目定義

    func testItemCountAndOrderMatchesScoringCriteria() {
        let criteria = FIMScoringCriteria.loadAll()
        XCTAssertEqual(criteria.count, 18, "FIM.json の設問数が18ではない")
        XCTAssertEqual(
            FIMItem.allCases.count, criteria.count,
            "FIMItem と FIM.json の項目数が食い違っている。評価画面で設問と項目がずれる"
        )
        // 表記ゆれのない項目で並び順の対応を確認する
        XCTAssertEqual(criteria[0].fimItem, FIMItem.eating.title)
        XCTAssertEqual(criteria[5].fimItem, FIMItem.toileting.title)
        XCTAssertEqual(criteria[12].fimItem, FIMItem.stairs.title)
        XCTAssertEqual(criteria[17].fimItem, FIMItem.memory.title)
    }

    func testMotorAndCognitionItemSplit() {
        XCTAssertEqual(FIMItem.motorItems.count, 13, "運動項目は13項目のはず")
        XCTAssertEqual(FIMItem.cognitionItems.count, 5, "認知項目は5項目のはず")
        XCTAssertEqual(FIMScore.fullScore, 126)
        XCTAssertEqual(FIMScore.motorFullScore, 91)
        XCTAssertEqual(FIMScore.cognitionFullScore, 35)
    }

    func testCategoryFullScoresMatchFIMDefinition() {
        // FIMの定義どおりの配点になっていること
        XCTAssertEqual(FIMCategory.selfCare.fullScore, 42)
        XCTAssertEqual(FIMCategory.sphincterControl.fullScore, 14)
        XCTAssertEqual(FIMCategory.transfers.fullScore, 21)
        XCTAssertEqual(FIMCategory.locomotion.fullScore, 14)
        XCTAssertEqual(FIMCategory.communication.fullScore, 14)
        XCTAssertEqual(FIMCategory.socialCognition.fullScore, 21)

        let sum = FIMCategory.allCases.reduce(0) { $0 + $1.fullScore }
        XCTAssertEqual(sum, FIMScore.fullScore, "大項目の満点合計が126点にならない")
    }

    // MARK: - 集計

    func testTotals() {
        let record = makeRecord()
        // 運動13項目: 7+6+5+4+3+2+0+1+7+6+5+4+3 = 53
        XCTAssertEqual(record.motorSubtotal, 53)
        // 認知5項目: 2+1+7+6+5 = 21
        XCTAssertEqual(record.cognitionSubtotal, 21)
        XCTAssertEqual(record.total, 74)
        XCTAssertEqual(record.motorSubtotal + record.cognitionSubtotal, record.total)
    }

    func testUnansweredItemsAreDetected() {
        let record = makeRecord()
        XCTAssertTrue(record.hasUnansweredItem)
        XCTAssertEqual(record.unansweredItems, [.bladderManagement])
        XCTAssertEqual(record.displayScore(for: .bladderManagement), "未入力")
        XCTAssertEqual(record.displayScore(for: .eating), "7")
    }

    func testScoresInitializerKeepsAssessmentOrder() {
        let record = FIMRecord(scores: [7, 6, 5, 4, 3, 2, 0, 1, 7, 6, 5, 4, 3, 2, 1, 7, 6, 5])
        XCTAssertEqual(record.eating, 7)
        XCTAssertEqual(record.bladderManagement, 0)
        XCTAssertEqual(record.stairs, 3)
        XCTAssertEqual(record.memory, 5)
    }

    // MARK: - コピー文字列

    func testCopyStringFormat() {
        let record = makeRecord()
        let text = FIMResultFormatter.string(from: record)

        XCTAssertTrue(text.hasPrefix("FIM評価結果"), "先頭が旧バージョンと異なる")
        // 未入力があるときは合計値に注記が付く（旧バージョンと同じ挙動）
        XCTAssertTrue(text.contains("合計値74　未入力項目あり"), "未入力の注記が出ていない:\n\(text)")
        XCTAssertTrue(text.contains("食事:7"))
        XCTAssertTrue(text.contains("排尿管理:未入力"))
        XCTAssertTrue(text.contains("記憶:5"))

        // 18項目すべてが並ぶ
        for item in FIMItem.allCases {
            XCTAssertTrue(text.contains("\(item.title):"), "\(item.title) がコピー結果に含まれていない")
        }
    }

    func testCopyStringWithoutUnansweredHasNoNote() {
        let record = FIMRecord(scores: Array(repeating: 7, count: 18))
        let text = FIMResultFormatter.string(from: record)
        XCTAssertTrue(text.contains("合計値126"))
        XCTAssertFalse(text.contains("未入力項目あり"), "未入力が無いのに注記が付いている")
    }

    // MARK: - PDF出力

    func testPDFContainsAllItemsAndTotal() throws {
        let record = makeRecord()
        let url = try XCTUnwrap(
            FIMPDFRenderer.writeToTemporaryDirectory(for: record),
            "PDFが書き出せていない"
        )
        defer { try? FileManager.default.removeItem(at: url) }

        let document = try XCTUnwrap(PDFDocument(url: url), "PDFとして読めない")
        XCTAssertGreaterThan(document.pageCount, 0, "PDFのページが無い")
        let text = try XCTUnwrap(document.string, "PDFからテキストを取り出せない")

        // 表題と大項目
        XCTAssertTrue(text.contains("FIM"), "表題が出ていない")
        for category in FIMCategory.allCases {
            XCTAssertTrue(text.contains(category.rawValue), "大項目『\(category.rawValue)』が出ていない")
        }
        // 18項目すべて
        for item in FIMItem.allCases {
            XCTAssertTrue(text.contains(item.title.prefix(2)), "項目『\(item.title)』が出ていない")
        }
        // 合計と未入力
        XCTAssertTrue(text.contains("74"), "合計点が出ていない")
        XCTAssertTrue(text.contains("未入力"), "未入力の表示が出ていない")
    }

    func testPDFFileNameUsesReadableDate() throws {
        let record = makeRecord()
        let url = try XCTUnwrap(FIMPDFRenderer.writeToTemporaryDirectory(for: record))
        defer { try? FileManager.default.removeItem(at: url) }

        // 旧バージョンはOptionalの説明文がそのままファイル名に入っていた。その退行がないこと
        XCTAssertFalse(url.lastPathComponent.contains("Optional"), "ファイル名にOptionalが混ざっている")
        XCTAssertTrue(url.lastPathComponent.hasPrefix("FIM-"))
        XCTAssertTrue(url.lastPathComponent.hasSuffix(".pdf"))
    }
}
