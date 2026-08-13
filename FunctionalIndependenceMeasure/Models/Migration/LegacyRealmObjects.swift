//
//  LegacyRealmObjects.swift
//  FunctionalIndependenceMeasure
//
//  旧バージョン（〜1.5.4）が保存した Realm ファイルを読み取るためだけの定義。
//
//  旧バージョンのクラス名（Assessor / TargetPerson / FIM）は SwiftData 側のモデル名と
//  衝突するため、Swiftの型名は Legacy 接頭辞を付けたうえで className() を上書きし、
//  Realm上のスキーマ名だけを当時のまま保っている。
//  プロパティ名もスキーマの一部なので、こちらも変更しないこと。
//

import Foundation
import RealmSwift

// MARK: - LegacyAssessor
final class LegacyAssessor: Object {
    @Persisted(primaryKey: true) var uuidString = ""
    @Persisted var name = ""
    @Persisted var targetPersons: List<LegacyTargetPerson>

    override class func className() -> String { "Assessor" }
}

// MARK: - LegacyTargetPerson
final class LegacyTargetPerson: Object {
    @Persisted(primaryKey: true) var uuidString = ""
    @Persisted var name = ""
    // 旧バージョンではプロパティ名が大文字の "FIM" だったため、そのまま合わせる
    // swiftlint:disable:next identifier_name
    @Persisted var FIM: List<LegacyFIM>
    @Persisted(originProperty: "targetPersons") var assessors: LinkingObjects<LegacyAssessor>

    override class func className() -> String { "TargetPerson" }
}

// MARK: - LegacyFIM
final class LegacyFIM: Object {
    @Persisted(primaryKey: true) var uuidString = ""
    @Persisted var eating = 0
    @Persisted var grooming = 0
    @Persisted var bathing = 0
    @Persisted var dressingUpperBody = 0
    @Persisted var dressingLowerBody = 0
    @Persisted var toileting = 0
    @Persisted var bladderManagement = 0
    @Persisted var bowelManagement = 0
    @Persisted var transfersBedChairWheelchair = 0
    @Persisted var transfersToilet = 0
    @Persisted var transfersBathShower = 0
    @Persisted var walkWheelchair = 0
    @Persisted var stairs = 0
    @Persisted var comprehension = 0
    @Persisted var expression = 0
    @Persisted var socialInteraction = 0
    @Persisted var problemSolving = 0
    @Persisted var memory = 0
    @Persisted var createdAt: Date?
    @Persisted var updatedAt: Date?
    @Persisted(originProperty: "FIM") var targetPersons: LinkingObjects<LegacyTargetPerson>

    override class func className() -> String { "FIM" }

    /// 評価順に並んだ得点
    var scoresInAssessmentOrder: [Int] {
        [
            eating, grooming, bathing, dressingUpperBody, dressingLowerBody, toileting,
            bladderManagement, bowelManagement,
            transfersBedChairWheelchair, transfersToilet, transfersBathShower,
            walkWheelchair, stairs,
            comprehension, expression, socialInteraction, problemSolving, memory
        ]
    }
}
