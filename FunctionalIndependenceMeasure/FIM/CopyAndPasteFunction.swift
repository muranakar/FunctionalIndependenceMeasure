//
//  CopyAndPasteFunction.swift
//  FunctionalIndependenceMeasure
//
//  Created by 村中令 on 2022/01/29.
//

import Foundation

class CopyAndPasteFunction {
    init(assessor: Assessor, targetPerson: TargetPerson, fim: FIM, createdAtString: String) {
        self.assessor = assessor
        self.targetPerson = targetPerson
        self.fim = fim
        self.createdAtString = createdAtString
    }

    private var assessor: Assessor
    private var targetPerson: TargetPerson
    private var fim: FIM
    private var createdAtString: String

    private var sumAll: String {
        if fim.eating == 0 ||
            fim.grooming == 0 ||
            fim.bathing == 0 ||
            fim.dressingUpperBody == 0 ||
            fim.dressingLowerBody == 0 ||
            fim.toileting == 0 ||
            fim.bladderManagement == 0 ||
            fim.bowelManagement == 0 ||
            fim.transfersBedChairWheelchair == 0 ||
            fim.transfersToilet == 0 ||
            fim.transfersBathShower == 0 ||
            fim.walkWheelchair == 0 ||
            fim.stairs == 0 ||
            fim.comprehension == 0 ||
            fim.expression == 0 ||
            fim.socialInteraction == 0 ||
            fim.problemSolving == 0 ||
            fim.memory == 0 {
            return "\(fim.sumAll)　未入力項目あり"
        } else {
            return "\(fim.sumAll)"
        }
    }

    private var eating: String {
        if fim.eating == 0 {
            return "未入力"
        } else {
            return "\(fim.eating)"
        }
    }
    private var grooming: String {
        if fim.grooming == 0 {
            return "未入力"
        } else {
            return "\(fim.grooming)"
        }
    }

    private var bathing: String {
        if fim.bathing == 0 {
            return "未入力"
        } else {
            return "\(fim.bathing)"
        }}

    private var dressingUpperBody: String {
        if fim.dressingUpperBody == 0 {
            return "未入力"
        } else {
            return "\(fim.dressingUpperBody)"
        }}
    private var dressingLowerBody: String {
        if fim.dressingLowerBody == 0 {
            return "未入力"
        } else {
            return "\(fim.dressingLowerBody)"
        }}

    private var toileting: String {
        if fim.toileting == 0 {
            return "未入力"
        } else {
            return "\(fim.toileting)"
        }}

    private var bladderManagement: String {
        if fim.bladderManagement == 0 {
            return "未入力"
        } else {
            return "\(fim.bladderManagement)"
        }}

    private var bowelManagement: String {
        if fim.bowelManagement == 0 {
            return "未入力"
        } else {
            return "\(fim.bowelManagement)"
        }}

    private var transfersBedChairWheelchair: String {
        if fim.transfersBedChairWheelchair == 0 {
            return "未入力"
        } else {
            return "\(fim.transfersBedChairWheelchair)"
        }}

    private var transfersToilet: String {
        if fim.transfersToilet == 0 {
            return "未入力"
        } else {
            return "\(fim.transfersToilet)"
        }}
    private var transfersBathShower: String {
        if fim.transfersBathShower == 0 {
            return "未入力"
        } else {
            return "\(fim.transfersBathShower)"
        }}
    private var walkWheelchair: String {
        if fim.walkWheelchair == 0 {
            return "未入力"
        } else {
            return "\(fim.walkWheelchair)"
        }}
    private var stairs: String {
        if fim.stairs == 0 {
            return "未入力"
        } else {
            return "\(fim.stairs)"
        }}
    private var comprehension: String {
        if fim.comprehension == 0 {
            return "未入力"
        } else {
            return "\(fim.comprehension)"
        }}
    private var expression: String {
        if fim.expression == 0 {
            return "未入力"
        } else {
            return "\(fim.expression)"
        }}
    private var socialInteraction: String {
        if fim.socialInteraction == 0 {
            return "未入力"
        } else {
            return "\(fim.socialInteraction)"
        }}
    private  var problemSolving: String {
        if fim.problemSolving == 0 {
            return "未入力"
        } else {
            return "\(fim.problemSolving)"
        }}
    private var memory: String {
        if fim.memory == 0 {return "未入力"
        } else {
            return "\(fim.memory)"
        }}

    var copyAndPasteString: String {
        // swiftlint:disable:next line_length
        return "FIM評価結果\n評価日\(createdAtString)\n評価者:\(assessor.name)\n対象者:\(targetPerson.name)\n合計値\(sumAll)\n食事:\(eating)\n整容:\(grooming)\n清拭:\(bathing)\n更衣上半身:\(dressingUpperBody)\n更衣下半身:\(dressingLowerBody)\nトイレ動作:\(toileting)\n排尿管理:\(bladderManagement)\n排便管理:\(bowelManagement)\nベッド・椅子・車椅子移乗:\(transfersBedChairWheelchair)\nトイレ移乗:\(transfersToilet)\n浴槽・シャワー移乗:\(transfersBathShower)\n歩行・車椅子:\(walkWheelchair)\n階段:\(stairs)\n理解:\(comprehension)\n表出:\(expression)\n社会的交流:\(socialInteraction)\n問題解決:\(problemSolving)\n記憶:\(memory)"
    }
}
