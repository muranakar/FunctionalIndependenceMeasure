//
//  FIM.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import Foundation
import RealmSwift

// MARK: - Assessor
class Assessor: Object {
    @objc dynamic var uuidString = UUID().uuidString
    @objc dynamic var name = ""
    var tagetPersons = List<TargetPerson>()
    var uuid: UUID? {
        UUID(uuidString: uuidString)
    }
    override class func primaryKey() -> String? {
        "uuidString"
    }

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

// MARK: -TagetPerson
class TargetPerson: Object {
    @objc dynamic var uuidString = UUID().uuidString
    @objc dynamic var name = ""
    var FIM = List<FIM>()
    var uuid: UUID? {
        UUID(uuidString: uuidString)
    }
    override class func primaryKey() -> String? {
        "uuidString"
    }

    convenience init(name: String) {
        self.init()
        self.name = name
    }
}

// MARK: -FIM
class FIM: Object {
    @objc dynamic var uuidString = UUID().uuidString
    @objc dynamic var eating = 0
    @objc dynamic var grooming = 0
    @objc dynamic var bathing = 0
    @objc dynamic var dressingUpperBody = 0
    @objc dynamic var dressingLowerBody  = 0
    @objc dynamic var toileting = 0
    @objc dynamic var bladderManagement = 0
    @objc dynamic var bowelManagement = 0
    @objc dynamic var transfersBedChairWheelchair = 0
    @objc dynamic var transfersToilet = 0
    @objc dynamic var transfersBathShower = 0
    @objc dynamic var walkWheelchair = 0
    @objc dynamic var stairs = 0
    @objc dynamic var comprehension = 0
    @objc dynamic var expression = 0
    @objc dynamic var socialInteraction = 0
    @objc dynamic var problemSolving = 0
    @objc dynamic var memory = 0
    @objc dynamic var createdAt: Date? = nil
    @objc dynamic var updatedAt: Date? = nil

    var SumTheMotorSubscaleIncludes: Int {
        eating + grooming + bathing + dressingUpperBody + dressingLowerBody + toileting + bladderManagement + bowelManagement + transfersBedChairWheelchair + transfersToilet + transfersBathShower + walkWheelchair + stairs
    }

    var SumTheCognitionSubscaleIncludes: Int {
        comprehension + expression + socialInteraction + problemSolving + memory
    }

    var uuid: UUID? {
        UUID(uuidString: uuidString)
    }

    override class func primaryKey() -> String? {
        "uuidString"
    }

    convenience init(
        eating: Int,grooming: Int,bathing: Int,dressingUpperBody: Int,dressingLowerBody: Int,toileting: Int,bladderManagement: Int,bowelManagement: Int,transfersBedChairWheelchair: Int,transfersToilet: Int,transfersBathShower: Int,walkWheelchair: Int,stairs: Int,comprehension: Int,expression: Int,socialInteraction: Int,problemSolving: Int,memory: Int) {
            self.init()
            self.eating = eating
            self.grooming = grooming
            self.bathing = bathing
            self.dressingUpperBody = dressingUpperBody
            self.dressingLowerBody = dressingLowerBody
            self.toileting = toileting
            self.bladderManagement = bladderManagement
            self.bowelManagement = bowelManagement
            self.transfersBedChairWheelchair = transfersBedChairWheelchair
            self.transfersToilet = transfersToilet
            self.transfersBathShower = transfersBathShower
            self.walkWheelchair = walkWheelchair
            self.stairs = stairs
            self.comprehension = comprehension
            self.expression = expression
            self.socialInteraction = socialInteraction
            self.problemSolving = problemSolving
            self.memory = memory
        }
}

