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

    private var copyFIMTextHandler: () -> Void = {  }

    @IBAction private func copyFIMText(_ sender: Any) {
        copyFIMTextHandler()
    }

    func configure(
        sumAll: String,
        sumMotor: String,
        sumCongnition: String,
        createdAt: String,
        updatedAt: String,
        copyFIMTextHandler: @escaping() -> Void
    ) {
        sumAllLabel.text = sumAll
        sumTheMotorSubscaleIncludesLabel.text = sumMotor
        sumTheCognitionSubscaleIncludesLabel.text = sumCongnition
        createdAtLabel.text = createdAt
        updatedAtLabel.text = updatedAt
        self.copyFIMTextHandler = copyFIMTextHandler
    }
}
