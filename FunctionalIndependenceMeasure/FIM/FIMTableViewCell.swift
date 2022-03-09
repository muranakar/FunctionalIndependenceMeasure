//
//  FIMTableViewCell.swift
//  FunctionalIndependenceMeasure
//
//  Created by 村中令 on 2021/12/27.
//

import UIKit

final class FIMTableViewCell: UITableViewCell {
    @IBOutlet weak private var sumAllLabel: UILabel!
    @IBOutlet weak private var sumTheMotorSubscaleIncludesLabel: UILabel!
    @IBOutlet weak private var notEnteredLabel: UILabel!
    @IBOutlet weak private var sumTheCognitionSubscaleIncludesLabel: UILabel!
    @IBOutlet weak private var createdAtLabel: UILabel!
    @IBOutlet weak private var updatedAtLabel: UILabel!
    @IBOutlet weak private var copytextButton: UIButton! {
        didSet {
            copytextButton.tintColor = Colors.mainColor
        }
    }
    private var copyFIMTextHandler: () -> Void = { }
    private var makeFIMPDFHandler: () -> Void = { }

    @IBAction private func copyFIMText(_ sender: Any) {
        copyFIMTextHandler()
    }
    @IBAction private func makeFIMPDF(_ sender: Any) {
        makeFIMPDFHandler()
    }

    func configure(
        fim: FIM,
        createdAt: String,
        updatedAt: String,
        copyFIMTextHandler: @escaping() -> Void,
        makeFIMPDFHandler: @escaping() -> Void
    ) {
        sumAllLabel.text = String(fim.sumAll)
        sumTheMotorSubscaleIncludesLabel.text = String(fim.sumTheMotorSubscaleIncludes)
        sumTheCognitionSubscaleIncludesLabel.text = String(fim.sumTheCognitionSubscaleIncludes)
        createdAtLabel.text = createdAt
        updatedAtLabel.text = updatedAt
        self.copyFIMTextHandler = copyFIMTextHandler
        self.makeFIMPDFHandler = makeFIMPDFHandler
    }

    func configureNotEnteredLabelTextEmptyString() {
        notEnteredLabel.text = ""
    }
    func configureNotEnteredLabelText() {
        notEnteredLabel.text = "未入力"
    }
}
