//
//  FIMTableViewCell.swift
//  FunctionalIndependenceMeasure
//
//  Created by 村中令 on 2021/12/27.
//

import UIKit

class FIMTableViewCell: UITableViewCell {
    @IBOutlet weak private var sumAllLabel: UILabel!
    @IBOutlet weak private var sumTheMotorSubscaleIncludesLabel: UILabel!
    @IBOutlet weak private var sumTheCognitionSubscaleIncludesLabel: UILabel!
    @IBOutlet weak private var createdAtLabel: UILabel!
    @IBOutlet weak private var updatedAtLabel: UILabel!

    func configure(
        sumAll: String,
        sumMotor: String,
        sumCongnition: String,
        createdAt: String,
        updatedAt: String ) {
        sumAllLabel.text = sumAll
        sumTheMotorSubscaleIncludesLabel.text = sumMotor
        sumTheCognitionSubscaleIncludesLabel.text = sumCongnition
        createdAtLabel.text = createdAt
        updatedAtLabel.text = updatedAt
    }
}
