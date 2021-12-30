//
//  EditFIMTableViewController.swift
//  FunctionalIndependenceMeasure
//
//  Created by 村中令 on 2021/12/29.
//

import UIKit

class EditFIMTableViewController: UITableViewController {
    //　画面遷移で値を受け取る変数
    var fimUUID: UUID?
    let fimRepository = FIMRepository()

    private var fim: FIM {
        let fim = fimRepository.loadFIM(fimUUID: fimUUID!)
        guard let fim = fim else { fatalError("fimの値が入っていない。メソッド名：[\(#function)]")}
        return fim
    }

    private var fimItemTitle: [String] {
        [
            "食事", "整容", "清拭",
            "更衣上半身", "更衣下半身", "トイレ動作", "排尿管理",
            "排便管理", "ベッド・椅子・車椅子移乗", "トイレ移乗",
            "浴槽・シャワー移乗", "歩行・車椅子", "階段",
             "理解", "表出", "社会的交流", "問題解決", "記憶"
        ]
    }

    private var fimItemNum: [Int] {
        [
            fim.eating,
            fim.grooming,
            fim.bathing,
            fim.dressingUpperBody,
            fim.dressingLowerBody,
            fim.toileting,
            fim.bladderManagement,
            fim.bowelManagement,
            fim.transfersBedChairWheelchair,
            fim.transfersToilet,
            fim.transfersBathShower,
            fim.walkWheelchair,
            fim.stairs,
            fim.comprehension,
            fim.expression,
            fim.socialInteraction,
            fim.problemSolving,
            fim.memory
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let targetPersonName =  fimRepository.loadTargetPerson(fimUUID: fimUUID!)?.name else {
            return
        }
        navigationItem.title = "対象者:\(targetPersonName)様"
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fimItemTitle.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! EditFIMTableViewCell
        cell.configue(labelText: fimItemTitle[indexPath.row], textFieldText: String(fimItemNum[indexPath.row]))
        return cell
    }
}
