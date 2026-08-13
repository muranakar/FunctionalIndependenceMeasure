//
//  AssessmentFlowUITests.swift
//  FunctionalIndependenceMeasureUITests
//
//  評価者の登録から評価の保存・再表示までを一通り操作して、
//  SwiftUI + SwiftData へ移行したあとも評価が正しく記録されることを確認する。
//

import XCTest

final class AssessmentFlowUITests: XCTestCase {

    private var app: XCUIApplication!

    private let itemCount = 18
    private let fullScore = 126

    /// 前に実行したテストのデータが端末に残るため、名前を毎回変えてテスト同士を独立させる
    private lazy var runID = String(UUID().uuidString.prefix(6))

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    /// 評価者登録 → 対象者登録 → FIM評価(全項目7点) → 結果確認 → 履歴確認
    func testAssessmentFlowSavesFullScore() throws {
        let assessorName = "評価者\(runID)"
        let targetPersonName = "対象者\(runID)"

        addAssessor(named: assessorName)
        tap(app.buttons[assessorName], "評価者の行")

        addTargetPerson(named: targetPersonName)
        tap(app.buttons[targetPersonName], "対象者の行")

        tap(app.buttons["評価する"], "評価するボタン")

        // 18項目すべてを7点で回答する
        for index in 0..<itemCount {
            let choice = app.buttons["score-7"].firstMatch
            XCTAssertTrue(
                choice.waitForExistence(timeout: 5),
                "\(index + 1)項目目の7点の選択肢が見つからない"
            )
            choice.tap()
            tap(app.buttons["決定"], "\(index + 1)項目目の決定ボタン")
        }

        // 合計126点、運動91点、認知35点として保存されている
        XCTAssertTrue(
            app.staticTexts["\(fullScore) / \(fullScore) 点"].waitForExistence(timeout: 5),
            "総合計が \(fullScore) 点になっていない"
        )
        XCTAssertTrue(app.staticTexts["91 / 91 点"].exists, "運動項目合計が91点になっていない")
        XCTAssertTrue(app.staticTexts["35 / 35 点"].exists, "認知項目合計が35点になっていない")

        tap(app.buttons["完了"], "完了ボタン")

        // 履歴に1件残っている
        tap(app.buttons["評価一覧をみる"], "評価一覧をみるボタン")
        XCTAssertTrue(
            app.staticTexts["\(fullScore) / \(fullScore) 点"].waitForExistence(timeout: 5),
            "履歴に評価結果が表示されていない"
        )
    }

    /// スキップした項目は未入力として扱われる
    func testSkippedItemIsRecordedAsUnanswered() throws {
        let assessorName = "スキップ評価者\(runID)"
        addAssessor(named: assessorName)
        tap(app.buttons[assessorName], "評価者の行")
        let targetPersonName = "スキップ対象者\(runID)"
        addTargetPerson(named: targetPersonName)
        tap(app.buttons[targetPersonName], "対象者の行")

        tap(app.buttons["評価する"], "評価するボタン")

        // 1項目目だけスキップし、残りは7点にする
        tap(app.buttons["スキップ"], "スキップボタン")
        for index in 1..<itemCount {
            let choice = app.buttons["score-7"].firstMatch
            XCTAssertTrue(choice.waitForExistence(timeout: 5), "\(index + 1)項目目の選択肢が見つからない")
            choice.tap()
            tap(app.buttons["決定"], "\(index + 1)項目目の決定ボタン")
        }

        // 7点×17項目 = 119点。未入力の警告も出る
        XCTAssertTrue(
            app.staticTexts["119 / \(fullScore) 点"].waitForExistence(timeout: 5),
            "スキップ分を除いた合計が119点になっていない"
        )
        XCTAssertTrue(
            app.staticTexts["未入力の項目が1件あります"].exists,
            "未入力の件数が表示されていない"
        )
    }

    /// 未選択のまま決定するとアラートが出る
    func testDecideWithoutSelectionShowsAlert() throws {
        let assessorName = "未選択評価者\(runID)"
        addAssessor(named: assessorName)
        tap(app.buttons[assessorName], "評価者の行")
        let targetPersonName = "未選択対象者\(runID)"
        addTargetPerson(named: targetPersonName)
        tap(app.buttons[targetPersonName], "対象者の行")

        tap(app.buttons["評価する"], "評価するボタン")
        tap(app.buttons["決定"], "決定ボタン")

        XCTAssertTrue(
            app.staticTexts["未選択"].waitForExistence(timeout: 5),
            "未選択のまま決定してもアラートが出ない"
        )
    }

    // MARK: - 補助

    private func addAssessor(named name: String) {
        tap(app.buttons["評価者を追加"], "評価者を追加ボタン")
        let field = app.textFields["評価者名"]
        XCTAssertTrue(field.waitForExistence(timeout: 5), "評価者名の入力欄が出ない")
        field.tap()
        field.typeText(name)
        tap(app.buttons["保存"], "保存ボタン")
    }

    private func addTargetPerson(named name: String) {
        tap(app.buttons["対象者を追加"], "対象者を追加ボタン")
        let field = app.textFields["対象者名"]
        XCTAssertTrue(field.waitForExistence(timeout: 5), "対象者名の入力欄が出ない")
        field.tap()
        field.typeText(name)
        tap(app.buttons["保存"], "保存ボタン")
    }

    private func tap(_ element: XCUIElement, _ description: String, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertTrue(element.waitForExistence(timeout: 10), "\(description)が見つからない", file: file, line: line)
        element.tap()
    }
}
