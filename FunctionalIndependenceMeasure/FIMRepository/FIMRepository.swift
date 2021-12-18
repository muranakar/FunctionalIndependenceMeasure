//
//  FIMRepository.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import Foundation
import RealmSwift

final class FIMRepository {

    private let realm = try! Realm()

    private var notificationToken: NotificationToken?

    func observeAssessor(notifier: @escaping () -> Void) {
        notificationToken = realm.objects(Assessor.self).observe { _ in notifier() }
    }

    func observeTargetPerson(notifier: @escaping () -> Void) {
        notificationToken = realm.objects(TargetPerson.self).observe { _ in notifier() }
    }

    func observeFIM(notifier: @escaping () -> Void) {
        notificationToken = realm.objects(FIM.self).observe { _ in notifier() }
    }


    // MARK: - AssessorRepository
    func loadAssessor() -> [Assessor]{
        let assessor = realm.objects(Assessor.self)
        return Array<Assessor>(assessor)
    }

    func loadAssessor(assessorUUID: UUID) -> Assessor?{
        let assessor = realm.object(ofType: Assessor.self, forPrimaryKey: assessorUUID.uuidString)
        return assessor
    }

    func loadAssessor(targetPersonUUID: UUID) -> Assessor? {
        guard let fetchedTargetPerson = realm.object(ofType: TargetPerson.self, forPrimaryKey: targetPersonUUID.uuidString) else { return nil }
        return fetchedTargetPerson.Assessors.first
    }


    func apppendAssessor(assesor: Assessor){
        try! realm.write{
            realm.add(assesor)
        }
    }
    func updateAssessor(uuid: UUID, name: String) {
        try! realm.write() {
            let assessor = realm.object(ofType: Assessor.self, forPrimaryKey: uuid.uuidString)
            assessor?.name = name
        }
    }

    func removeAssessor(uuid: UUID) {
        guard let assessor = realm.object(ofType: Assessor.self, forPrimaryKey: uuid.uuidString) else { return }
        try! realm.write() {
            realm.delete(assessor)
        }
    }

    // MARK: - TargetPersonRepository
    func loadTargetPerson(AssessorUUID: UUID) -> [TargetPerson] {
        let assessor = realm.object(ofType: Assessor.self, forPrimaryKey: AssessorUUID.uuidString)
        guard let targetPerson = assessor?.targetPersons else { return [] }
        return Array<TargetPerson>(targetPerson)
    }

    func loadTargetPerson(targetPersonUUID: UUID) -> TargetPerson?{
        let targetPerson = realm.object(ofType: TargetPerson.self, forPrimaryKey: targetPersonUUID.uuidString)
        return targetPerson
    }

    func loadTargetPerson(fimUUID: UUID) -> TargetPerson? {
        guard let fetchedFIM = realm.object(ofType: FIM.self, forPrimaryKey: fimUUID.uuidString) else { return nil }
        return fetchedFIM.targetPersons.first
    }

    func appendTargetPerson(assessorUUID: UUID, targetPerson: TargetPerson) {
        guard let list = realm.object(ofType: Assessor.self, forPrimaryKey: assessorUUID.uuidString)?.targetPersons else { return }
        try! realm.write {
            list.append(targetPerson)
        }
    }

    func updateTargetPerson(uuid: UUID,name: String) {
        try! realm.write {
            let targetPerson = realm.object(ofType: TargetPerson.self, forPrimaryKey: uuid.uuidString)
            targetPerson?.name = name
        }
    }

    func removeTargetPerson(targetPersonUUID: UUID) {
        guard let fetchedTagetPerson = realm.object(ofType: TargetPerson.self, forPrimaryKey: targetPersonUUID.uuidString) else { return }
        try! realm.write {
            realm.delete(fetchedTagetPerson)
        }

    }

    // MARK: - FIMRepository
    func loadFIM(targetPersonUUID: UUID) -> [FIM] {
        let fimList = realm.object(ofType: TargetPerson.self, forPrimaryKey: targetPersonUUID.uuidString)?.FIM
        guard let fimList = fimList else { return [] }
        return Array<FIM>(fimList)
    }

    func appendFIM(targetPersonUUID: UUID, fim: FIM) {
        guard let list = realm.object(ofType: TargetPerson.self, forPrimaryKey: targetPersonUUID.uuidString)?.FIM else { return }
        try! realm.write {
            fim.createdAt = Date()
            list.append(fim)
        }
    }

    func updateFIM(fim: FIM) {
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

    func removeFIM(fimUUID: UUID) {
        guard let fetchedFIM = realm.object(ofType: FIM.self, forPrimaryKey: fimUUID.uuidString) else { return }
        try! realm.write {
            realm.delete(fetchedFIM)
        }
    }
}

