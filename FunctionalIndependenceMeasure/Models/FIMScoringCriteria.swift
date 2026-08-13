//
//  FIMScoringCriteria.swift
//  FunctionalIndependenceMeasure
//
//  FIM.json の採点基準。JSONのフォーマットは旧バージョンから変更していないため、
//  既存の FIM.json をそのまま読み込める。
//

import Foundation

struct FIMScoringCriteria: Decodable, Identifiable {
    let fimItem: String
    let seven: String
    let six: String
    let five: String
    let four: String
    let three: String
    let two: String
    let one: String
    let attention: String

    var id: String { fimItem }

    /// 得点（1〜7）に対応する採点基準の説明
    func description(for score: Int) -> String {
        switch score {
        case 7: seven
        case 6: six
        case 5: five
        case 4: four
        case 3: three
        case 2: two
        case 1: one
        default: ""
        }
    }
}

// MARK: - 読み込み
extension FIMScoringCriteria {
    /// バンドルの FIM.json を評価順に読み込む
    static func loadAll() -> [FIMScoringCriteria] {
        guard let url = Bundle.main.url(forResource: "FIM", withExtension: "json") else {
            assertionFailure("FIM.json がバンドルに含まれていません")
            return []
        }
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([FIMScoringCriteria].self, from: data)
        } catch {
            assertionFailure("FIM.json の読み込みに失敗しました: \(error)")
            return []
        }
    }
}
