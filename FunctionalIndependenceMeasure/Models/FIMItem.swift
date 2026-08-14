//
//  FIMItem.swift
//  FunctionalIndependenceMeasure
//
//  FIMの18項目とその区分。並び順は FIM.json および旧バージョンの評価順と一致させている。
//

import Foundation

// MARK: - FIMCategory
/// FIMの大項目
enum FIMCategory: String, CaseIterable, Identifiable {
    case selfCare = "セルフケア"
    case sphincterControl = "排泄"
    case transfers = "移乗"
    case locomotion = "移動"
    case communication = "コミュニケーション"
    case socialCognition = "社会認識"

    var id: String { rawValue }

    /// この区分の満点
    var fullScore: Int {
        items.count * FIMScore.max
    }

    var items: [FIMItem] {
        FIMItem.allCases.filter { $0.category == self }
    }
}

// MARK: - FIMScore
enum FIMScore {
    /// 未入力を表す値。旧バージョンから 0 を未入力として扱っている
    static let unanswered = 0
    static let min = 1
    static let max = 7
    static let range = min...max

    /// 全項目合計の満点（18項目 × 7点）
    static let fullScore = FIMItem.allCases.count * max
    /// 運動項目の満点（13項目 × 7点）
    static let motorFullScore = FIMItem.motorItems.count * max
    /// 認知項目の満点（5項目 × 7点）
    static let cognitionFullScore = FIMItem.cognitionItems.count * max
}

// MARK: - FIMItem
/// FIMの評価項目
enum FIMItem: Int, CaseIterable, Identifiable {
    case eating
    case grooming
    case bathing
    case dressingUpperBody
    case dressingLowerBody
    case toileting
    case bladderManagement
    case bowelManagement
    case transfersBedChairWheelchair
    case transfersToilet
    case transfersBathShower
    case walkWheelchair
    case stairs
    case comprehension
    case expression
    case socialInteraction
    case problemSolving
    case memory

    var id: Int { rawValue }

    /// 一覧・詳細で表示する項目名
    var title: String {
        switch self {
        case .eating: "食事"
        case .grooming: "整容"
        case .bathing: "清拭"
        case .dressingUpperBody: "更衣上半身"
        case .dressingLowerBody: "更衣下半身"
        case .toileting: "トイレ動作"
        case .bladderManagement: "排尿管理"
        case .bowelManagement: "排便管理"
        case .transfersBedChairWheelchair: "ベッド・椅子・車椅子移乗"
        case .transfersToilet: "トイレ移乗"
        case .transfersBathShower: "浴槽・シャワー移乗"
        case .walkWheelchair: "歩行・車椅子"
        case .stairs: "階段"
        case .comprehension: "理解"
        case .expression: "表出"
        case .socialInteraction: "社会的交流"
        case .problemSolving: "問題解決"
        case .memory: "記憶"
        }
    }

    /// PDFの表で使う記号付きの項目名
    var pdfTitle: String {
        switch self {
        case .eating: "A　食事（箸・スプーン）"
        case .grooming: "B　整容"
        case .bathing: "C　清拭"
        case .dressingUpperBody: "D　更衣（上半身）"
        case .dressingLowerBody: "E　更衣（下半身）"
        case .toileting: "F　トイレ"
        case .bladderManagement: "G　排尿コントロール"
        case .bowelManagement: "H　排便コントロール"
        case .transfersBedChairWheelchair: "I　ベッド、椅子、車椅子"
        case .transfersToilet: "J　トイレ"
        case .transfersBathShower: "K　浴槽、シャワー"
        case .walkWheelchair: "L　歩行、車椅子"
        case .stairs: "M　階段"
        case .comprehension: "N　理解（聴覚、視覚）"
        case .expression: "O　表出（音声、非音声）"
        case .socialInteraction: "P　社会的交流"
        case .problemSolving: "Q　問題解決"
        case .memory: "R　記憶"
        }
    }

    var category: FIMCategory {
        switch self {
        case .eating, .grooming, .bathing, .dressingUpperBody, .dressingLowerBody, .toileting:
            .selfCare
        case .bladderManagement, .bowelManagement:
            .sphincterControl
        case .transfersBedChairWheelchair, .transfersToilet, .transfersBathShower:
            .transfers
        case .walkWheelchair, .stairs:
            .locomotion
        case .comprehension, .expression:
            .communication
        case .socialInteraction, .problemSolving, .memory:
            .socialCognition
        }
    }

    /// 運動項目かどうか（前半13項目）
    var isMotor: Bool {
        switch category {
        case .selfCare, .sphincterControl, .transfers, .locomotion: true
        case .communication, .socialCognition: false
        }
    }

    static var motorItems: [FIMItem] { allCases.filter(\.isMotor) }
    static var cognitionItems: [FIMItem] { allCases.filter { !$0.isMotor } }
}
