//
//  SwiftDataModels.swift
//  FunctionalIndependenceMeasure
//
//  Realm から SwiftData へ移行したモデル定義。
//  uuidString は旧Realmの主キーをそのまま引き継ぐ（移行時の同一性担保のため）。
//

import Foundation
import SwiftData

// MARK: - Assessor
/// 評価者
@Model
final class Assessor {
    @Attribute(.unique) var uuidString: String = ""
    var name: String = ""
    var createdAt: Date = Date.distantPast

    @Relationship(deleteRule: .cascade, inverse: \TargetPerson.assessor)
    var targetPersons: [TargetPerson] = []

    init(uuidString: String = UUID().uuidString, name: String, createdAt: Date = .now) {
        self.uuidString = uuidString
        self.name = name
        self.createdAt = createdAt
    }
}

// MARK: - TargetPerson
/// 対象者
@Model
final class TargetPerson {
    @Attribute(.unique) var uuidString: String = ""
    var name: String = ""
    var createdAt: Date = Date.distantPast

    var assessor: Assessor?

    @Relationship(deleteRule: .cascade, inverse: \FIMRecord.targetPerson)
    var fimRecords: [FIMRecord] = []

    init(uuidString: String = UUID().uuidString, name: String, createdAt: Date = .now) {
        self.uuidString = uuidString
        self.name = name
        self.createdAt = createdAt
    }
}

// MARK: - FIMRecord
/// FIM評価1回分
@Model
final class FIMRecord {
    @Attribute(.unique) var uuidString: String = ""

    var eating: Int = 0
    var grooming: Int = 0
    var bathing: Int = 0
    var dressingUpperBody: Int = 0
    var dressingLowerBody: Int = 0
    var toileting: Int = 0
    var bladderManagement: Int = 0
    var bowelManagement: Int = 0
    var transfersBedChairWheelchair: Int = 0
    var transfersToilet: Int = 0
    var transfersBathShower: Int = 0
    var walkWheelchair: Int = 0
    var stairs: Int = 0
    var comprehension: Int = 0
    var expression: Int = 0
    var socialInteraction: Int = 0
    var problemSolving: Int = 0
    var memory: Int = 0

    var createdAt: Date = Date.distantPast
    var updatedAt: Date?

    var targetPerson: TargetPerson?

    init(uuidString: String = UUID().uuidString, createdAt: Date = .now, updatedAt: Date? = nil) {
        self.uuidString = uuidString
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    /// 評価順に並んだ18個の得点から生成する
    convenience init(scores: [Int], createdAt: Date = .now) {
        self.init(createdAt: createdAt)
        for (index, item) in FIMItem.allCases.enumerated() {
            self[item] = scores.indices.contains(index) ? scores[index] : FIMScore.unanswered
        }
    }
}

// MARK: - 項目アクセス
extension FIMRecord {
    /// 項目を指定して得点を読み書きする
    subscript(item: FIMItem) -> Int {
        get {
            switch item {
            case .eating: eating
            case .grooming: grooming
            case .bathing: bathing
            case .dressingUpperBody: dressingUpperBody
            case .dressingLowerBody: dressingLowerBody
            case .toileting: toileting
            case .bladderManagement: bladderManagement
            case .bowelManagement: bowelManagement
            case .transfersBedChairWheelchair: transfersBedChairWheelchair
            case .transfersToilet: transfersToilet
            case .transfersBathShower: transfersBathShower
            case .walkWheelchair: walkWheelchair
            case .stairs: stairs
            case .comprehension: comprehension
            case .expression: expression
            case .socialInteraction: socialInteraction
            case .problemSolving: problemSolving
            case .memory: memory
            }
        }
        set {
            switch item {
            case .eating: eating = newValue
            case .grooming: grooming = newValue
            case .bathing: bathing = newValue
            case .dressingUpperBody: dressingUpperBody = newValue
            case .dressingLowerBody: dressingLowerBody = newValue
            case .toileting: toileting = newValue
            case .bladderManagement: bladderManagement = newValue
            case .bowelManagement: bowelManagement = newValue
            case .transfersBedChairWheelchair: transfersBedChairWheelchair = newValue
            case .transfersToilet: transfersToilet = newValue
            case .transfersBathShower: transfersBathShower = newValue
            case .walkWheelchair: walkWheelchair = newValue
            case .stairs: stairs = newValue
            case .comprehension: comprehension = newValue
            case .expression: expression = newValue
            case .socialInteraction: socialInteraction = newValue
            case .problemSolving: problemSolving = newValue
            case .memory: memory = newValue
            }
        }
    }
}

// MARK: - 集計
extension FIMRecord {
    /// 運動項目合計
    var motorSubtotal: Int {
        FIMItem.motorItems.reduce(0) { $0 + self[$1] }
    }

    /// 認知項目合計
    var cognitionSubtotal: Int {
        FIMItem.cognitionItems.reduce(0) { $0 + self[$1] }
    }

    /// 総合計
    var total: Int {
        FIMItem.allCases.reduce(0) { $0 + self[$1] }
    }

    /// 未入力（0点）の項目
    var unansweredItems: [FIMItem] {
        FIMItem.allCases.filter { self[$0] == FIMScore.unanswered }
    }

    var hasUnansweredItem: Bool {
        !unansweredItems.isEmpty
    }

    /// 得点の表示用文字列。未入力は「未入力」と表示する
    func displayScore(for item: FIMItem) -> String {
        let score = self[item]
        return score == FIMScore.unanswered ? "未入力" : String(score)
    }
}
