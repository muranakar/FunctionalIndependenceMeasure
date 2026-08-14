//
//  Route.swift
//  FunctionalIndependenceMeasure
//
//  同じ TargetPerson から「評価する」「評価一覧をみる」の2方向へ分岐するため、
//  遷移先を型ではなく列挙で表現している。
//

import Foundation

enum Route: Hashable {
    /// 新規にFIM評価を行う
    case newAssessment(TargetPerson)
    /// 過去のFIM評価一覧
    case fimRecords(TargetPerson)
    /// 評価結果の詳細
    case fimDetail(FIMRecord)
}
