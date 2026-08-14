//
//  FIMResultFormatter.swift
//  FunctionalIndependenceMeasure
//
//  評価結果をクリップボード用テキストへ整形する。書式は旧バージョンと揃えている。
//

import Foundation

enum FIMResultFormatter {
    static func string(from record: FIMRecord) -> String {
        let targetPersonName = record.targetPerson?.name ?? "-"
        let assessorName = record.targetPerson?.assessor?.name ?? "-"
        let createdAt = DateFormatter.evaluated.string(from: record.createdAt)

        // 未入力の項目が1つでもあれば、合計値だけでは判断できないため注記を添える
        let total = record.hasUnansweredItem ? "\(record.total)　未入力項目あり" : "\(record.total)"

        let itemLines = FIMItem.allCases
            .map { "\($0.title):\(record.displayScore(for: $0))" }
            .joined(separator: "\n")

        return """
        FIM評価結果
        評価日\(createdAt)
        評価者:\(assessorName)
        対象者:\(targetPersonName)
        合計値\(total)
        \(itemLines)
        """
    }
}
