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
    // 【あとからボタンを追加した際のコードに関して】
    //　あとからボタンを追加しました（copytextButton）。そのボタンに色を付けたい場合、
    // 毎回configueメソッドの引数に、UIColorを設定して、メソッド内で、copytextButton = color【←引数（UIColor）】と設定しないと行けないのか。
    @IBOutlet weak var copytextButton: UIButton!
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
