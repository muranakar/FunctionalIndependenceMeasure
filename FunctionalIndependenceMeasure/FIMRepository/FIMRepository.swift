//
//  FIMRepository.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import Foundation
import RealmSwift

final class FIMRepository {
    // swiftlint:disable:next force_cast
    private let realm = try! Realm()

    // MARK: - AssessorRepository
    // 全評価者の呼び出し
    func loadAssessor() -> [Assessor] {
        let assessors = realm.objects(Assessor.self)
        let assessorsArray = Array(assessors)
        return assessorsArray
    }
    // 評価者UUIDによる評価者（一人）の呼び出し
    func loadAssessor(assessorUUID: UUID) -> Assessor? {
        let assessor = realm.object(ofType: Assessor.self, forPrimaryKey: assessorUUID.uuidString)
        return assessor
    }
    // 対象者UUIDによる評価者（一人）の呼び出し
    func loadAssessor(targetPersonUUID: UUID) -> Assessor? {
        guard let fetchedTargetPerson = realm.object(
            ofType: TargetPerson.self,
            forPrimaryKey: targetPersonUUID.uuidString
        ) else { return nil }
        return fetchedTargetPerson.assessors.first
    }
    //　評価者の追加
    func apppendAssessor(assesor: Assessor) {
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.add(assesor)
        }
    }
    // 評価者の更新
    func updateAssessor(uuid: UUID, name: String) {
        // swiftlint:disable:next force_cast
        try! realm.write {
            let assessor = realm.object(ofType: Assessor.self, forPrimaryKey: uuid.uuidString)
            assessor?.name = name
        }
    }
    // 評価者の削除
    func removeAssessor(uuid: UUID) {
        guard let assessor = realm.object(ofType: Assessor.self, forPrimaryKey: uuid.uuidString) else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.delete(assessor)
        }
    }

    // MARK: - TargetPersonRepository
    // 一人の評価者が評価するor評価した、対象者の配列の呼び出し
    func loadTargetPerson(assessorUUID: UUID) -> [TargetPerson] {
        let assessor = realm.object(ofType: Assessor.self, forPrimaryKey: assessorUUID.uuidString)
        guard let targetPersons = assessor?.targetPersons else { return [] }
        let targetPersonsArray = Array(targetPersons)
        return targetPersonsArray
    }
    // 一人の対象者のUUIDから、一人の対象者の呼び出し
    func loadTargetPerson(targetPersonUUID: UUID) -> TargetPerson? {
        let targetPerson = realm.object(ofType: TargetPerson.self, forPrimaryKey: targetPersonUUID.uuidString)
        return targetPerson
    }

    // 一つのFIMのUUIDから、そのFIMがどの対象者かの呼び出し
    func loadTargetPerson(fimUUID: UUID) -> TargetPerson? {
        guard let fetchedFIM = realm.object(ofType: FIM.self, forPrimaryKey: fimUUID.uuidString) else { return nil }
        return fetchedFIM.targetPersons.first
    }
    //  一人の評価者の対象者の追加
    func appendTargetPerson(assessorUUID: UUID, targetPerson: TargetPerson) {
        guard let list = realm.object(
            ofType: Assessor.self,
            forPrimaryKey: assessorUUID.uuidString
        )?.targetPersons else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            list.append(targetPerson)
        }
    }
    // 一人の対象者のデータ更新
    func updateTargetPerson(uuid: UUID, name: String) {
        try! realm.write {
            let targetPerson = realm.object(ofType: TargetPerson.self, forPrimaryKey: uuid.uuidString)
            targetPerson?.name = name
        }
    }
    // 一人の対象者のデータ削除
    func removeTargetPerson(targetPersonUUID: UUID) {
        guard let fetchedTagetPerson = realm.object(
            ofType: TargetPerson.self,
            forPrimaryKey: targetPersonUUID.uuidString
        ) else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.delete(fetchedTagetPerson)
        }
    }

    // MARK: - FIMRepository
    // 一つのFIMのUUIDから、FIMのデータの呼び出し
    func loadFIM(fimUUID: UUID) -> FIM? {
        let fim = realm.object(ofType: FIM.self, forPrimaryKey: fimUUID.uuidString)
        return fim
    }
    //　一人の対象者のUUIDから、複数のFIMのデータの呼び出し
    func loadFIM(targetPersonUUID: UUID) -> [FIM] {
        let fimList = realm.object(ofType: TargetPerson.self, forPrimaryKey: targetPersonUUID.uuidString)?.FIM
        guard let fimList = fimList else { return [] }
        let fimListArray = Array(fimList)
        return fimListArray
    }
    //  一人の対象者のFIMデータの追加
    func appendFIM(targetPersonUUID: UUID, fim: FIM) {
        guard let list = realm.object(
            ofType: TargetPerson.self,
            forPrimaryKey: targetPersonUUID.uuidString
        )?.FIM else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            fim.createdAt = Date()
            list.append(fim)
        }
    }
    // FIMデータの更新
    // 【気になる点】
    // データ更新の項目数が多く、一つのモデルオブジェクト（Realmだから、モデルオブジェクト？構造体ではなく？）にまとめて、そのデータを代入して
    //　FIMの値を更新しようと試みたが、書き換えた　FIM　を引数として、代入すると、更新ができない。
    // REONさんに、助言を頂きましたが、その解決策がわかりませんでした。
    // realm.writeの中で、データを書き換えなければならず、どのように実装すればよいかがわからなかった。

    // 私の方法・・・項目ごとの結果を引数に渡して、realm.write内で、更新データを取り出して、代入する。
    //　→私の方法であれば、項目数が増えてしまい、今後コードを修正に困る、というデメリットがあります。

    func updateFIM(fim: FIM) {
        // swiftlint:disable:next force_cast
        try! realm.write {
            fim.updatedAt = Date()
            realm.add(fim, update: .modified)
            //            loadedFIM.eating = fim.eating
            //            loadedFIM.grooming = fim.grooming
            //            loadedFIM.bathing = fim.bathing
            //            loadedFIM.dressingUpperBody = fim.dressingUpperBody
            //            loadedFIM.dressingLowerBody = fim.dressingLowerBody
            //            loadedFIM.toileting = fim.toileting
            //            loadedFIM.bladderManagement = fim.bladderManagement
            //            loadedFIM.bowelManagement = fim.bowelManagement
            //            loadedFIM.transfersBedChairWheelchair = fim.transfersBedChairWheelchair
            //            loadedFIM.transfersToilet = fim.transfersToilet
            //            loadedFIM.transfersBathShower = fim.transfersBathShower
            //            loadedFIM.walkWheelchair = fim.walkWheelchair
            //            loadedFIM.stairs = fim.stairs
            //            loadedFIM.comprehension = fim.comprehension
            //            loadedFIM.expression = fim.expression
            //            loadedFIM.socialInteraction = fim.socialInteraction
            //            loadedFIM.problemSolving = fim.problemSolving
            //            loadedFIM.memory = fim.memory
        }
    }
    // FIMデータの削除
    func removeFIM(fimUUID: UUID) {
        guard let fetchedFIM = realm.object(ofType: FIM.self, forPrimaryKey: fimUUID.uuidString) else { return }
        // swiftlint:disable:next force_cast
        try! realm.write {
            realm.delete(fetchedFIM)
        }
    }
}
