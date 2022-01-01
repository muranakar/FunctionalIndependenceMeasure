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
        fim: FIM,
        createdAt: String,
        updatedAt: String,
        copyFIMTextHandler: @escaping() -> Void
    ) {
        sumAllLabel.text = String(fim.sumAll)
        sumTheMotorSubscaleIncludesLabel.text = String(fim.sumTheMotorSubscaleIncludes)
        sumTheCognitionSubscaleIncludesLabel.text = String(fim.sumTheCognitionSubscaleIncludes)
        createdAtLabel.text = createdAt
        updatedAtLabel.text = updatedAt
        self.copyFIMTextHandler = copyFIMTextHandler
    }
}
