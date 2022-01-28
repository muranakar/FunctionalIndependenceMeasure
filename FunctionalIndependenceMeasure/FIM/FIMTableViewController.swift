//
//  FIMTableViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit
import Foundation

final class FIMTableViewController: UITableViewController {
    //　画面遷移で値を受け取る変数
    var targetPersonUUID: UUID?

    // 画面遷移先へ値を渡す変数
    var selectedFIMUUID: UUID?
    var editingFIMUUID: UUID?

    //　並び替えのための変数
    private var isSortedAscending = false

    let fimRepository = FIMRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let targetPersonName =  fimRepository.loadTargetPerson(targetPersonUUID: targetPersonUUID!)?.name else {
            return
        }
        navigationItem.title = "対象者:　\(targetPersonName)　様"
        tableView.register(UINib(nibName: "FIMTableViewCell", bundle: nil), forCellReuseIdentifier: "FIMTableViewCell")
        tableView.reloadData()
        configueViewNavigationbarColor()
    }

    // MARK: - Segue- FIMTableViewController →　InputTargetPersonViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nav = segue.destination as? UINavigationController else { return }
        if let detailFIMVC = nav.topViewController as? DetailFIMViewController {
            switch segue.identifier ?? "" {
            case "detailFIM":
                detailFIMVC.fimUUID = selectedFIMUUID
                // このmodeによって、画面遷移先の次の画面遷移先を決めている。
                detailFIMVC.mode = .fim
            default:
                break
            }
        }
    }

    // MARK: - Segue- FIMTableViewController ←　InputFIMViewController
    @IBAction private func backToFIMTableViewController(segue: UIStoryboardSegue) {
        tableView.reloadData()
    }

    // MARK: - Segue- SortTableView

    @IBAction private func sortTableView(_ sender: Any) {
        isSortedAscending.toggle()
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fimRepository.loadFIM(
            targetPersonUUID: targetPersonUUID!,
            sortedAscending: isSortedAscending
        ).count
    }
    // MARK: - リファクタリング必要あり。
    // リファクタリングする必要あり
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:enable cyclomatic_complexity
        // swiftlint:enable function_body_length

        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "FIMTableViewCell") as! FIMTableViewCell
        let fim = fimRepository.loadFIM(
            targetPersonUUID: targetPersonUUID!,
            sortedAscending: isSortedAscending
        )[indexPath.row]
        guard let targetPerson = fimRepository.loadTargetPerson(fimUUID: fim.uuid!) else {
            fatalError()
        }
        guard let assessor = fimRepository.loadAssessor(targetPersonUUID: targetPerson.uuid!) else { fatalError()}
        var createdAtString = "--"
        var updateAtString = "--"
        if let createdAt = fim.createdAt {
            createdAtString  = dateFormatter(date: createdAt)
        }
        if let updateAt = fim.updatedAt {
            updateAtString = dateFormatter(date: updateAt)
        }
        // MARK: - 修正必要あり部分

        var sumAll: String {
            if fim.eating == 0,
               fim.grooming == 0,
               fim.bathing == 0,
               fim.dressingUpperBody == 0,
               fim.dressingLowerBody == 0,
               fim.toileting == 0,
               fim.bladderManagement == 0,
               fim.bowelManagement == 0,
               fim.transfersBedChairWheelchair == 0,
               fim.transfersToilet == 0,
               fim.transfersBathShower == 0,
               fim.walkWheelchair == 0,
               fim.stairs == 0,
               fim.comprehension == 0,
               fim.expression == 0,
               fim.socialInteraction == 0,
               fim.problemSolving == 0,
               fim.memory == 0 {
                return "\(fim.sumAll)　未入力項目あり"
            } else {
                return "\(fim.sumAll)"
            }
        }

        var eating: String {
            if fim.eating == 0 {
                return "未入力"
            } else {
                return "\(fim.eating)"
            }
        }
        var grooming: String {
            if fim.grooming == 0 {
                return "未入力"
            } else {
                return "\(fim.grooming)"
            }
        }

        var bathing: String {
            if fim.bathing == 0 {
                return "未入力"
            } else {
                return "\(fim.bathing)"
            }}

        var dressingUpperBody: String {
            if fim.dressingUpperBody == 0 {
                return "未入力"
            } else {
                return "\(fim.dressingUpperBody)"
            }}
        var dressingLowerBody: String {
            if fim.dressingLowerBody == 0 {
                return "未入力"
            } else {
                return "\(fim.dressingLowerBody)"
            }}

        var toileting: String {
            if fim.toileting == 0 {
                return "未入力"
            } else {
                return "\(fim.toileting)"
            }}

        var bladderManagement: String {
            if fim.bladderManagement == 0 {
                return "未入力"
            } else {
                return "\(fim.bladderManagement)"
            }}

        var bowelManagement: String {
            if fim.bowelManagement == 0 {
                return "未入力"
            } else {
                return "\(fim.bowelManagement)"
            }}

        var transfersBedChairWheelchair: String {
            if fim.transfersBedChairWheelchair == 0 {
                return "未入力"
            } else {
                return "\(fim.transfersBedChairWheelchair)"
            }}

        var transfersToilet: String {
            if fim.transfersToilet == 0 {
                return "未入力"
            } else {
                return "\(fim.transfersToilet)"
            }}
        var transfersBathShower: String {
            if fim.transfersBathShower == 0 {
                return "未入力"
            } else {
                return "\(fim.transfersBathShower)"
            }}
        var walkWheelchair: String {
            if fim.walkWheelchair == 0 {
                return "未入力"
            } else {
                return "\(fim.walkWheelchair)"
            }}
        var stairs: String {
            if fim.stairs == 0 {
                return "未入力"
            } else {
                return "\(fim.stairs)"
            }}
        var comprehension: String {
            if fim.comprehension == 0 {
                return "未入力"
            } else {
                return "\(fim.comprehension)"
            }}
        var expression: String {
            if fim.expression == 0 {
                return "未入力"
            } else {
                return "\(fim.expression)"
            }}
        var socialInteraction: String {
            if fim.socialInteraction == 0 {
                return "未入力"
            } else {
                return "\(fim.socialInteraction)"
            }}
        var problemSolving: String {
            if fim.problemSolving == 0 {
                return "未入力"
            } else {
                return "\(fim.problemSolving)"
            }}
        var memory: String {
            if fim.memory == 0 {return "未入力"
            } else {
                return "\(fim.memory)"
            }}
        // MARK: - ここまで修正必要
        cell.configure(
            fim: fim,
            createdAt: createdAtString,
            updatedAt: updateAtString,
            copyFIMTextHandler: {
                UIPasteboard.general.string =
                // swiftlint:disable:next line_length
                "FIM評価結果\n評価日\(createdAtString)\n評価者:\(assessor.name)\n対象者:\(targetPerson.name)\n合計値\(sumAll)\n食事:\(eating)\n整容:\(grooming)\n清拭:\(bathing)\n更衣上半身:\(dressingUpperBody)\n更衣下半身:\(dressingLowerBody)\nトイレ動作:\(toileting)\n排尿管理:\(bladderManagement)\n排便管理:\(bowelManagement)\nベッド・椅子・車椅子移乗:\(transfersBedChairWheelchair)\nトイレ移乗:\(transfersToilet)\n浴槽・シャワー移乗:\(transfersBathShower)\n歩行・車椅子:\(walkWheelchair)\n階段:\(stairs)\n理解:\(comprehension)\n表出:\(expression)\n社会的交流:\(socialInteraction)\n問題解決:\(problemSolving)\n記憶:\(memory)"
            })

        // fimの項目の中に、未入力があると、未入力ラベルが表示される。
        if fim.eating == 0,
           fim.grooming == 0,
           fim.bathing == 0,
           fim.dressingUpperBody == 0,
           fim.dressingLowerBody == 0,
           fim.toileting == 0,
           fim.bladderManagement == 0,
           fim.bowelManagement == 0,
           fim.transfersBedChairWheelchair == 0,
           fim.transfersToilet == 0,
           fim.transfersBathShower == 0,
           fim.walkWheelchair == 0,
           fim.stairs == 0,
           fim.comprehension == 0,
           fim.expression == 0,
           fim.socialInteraction == 0,
           fim.problemSolving == 0,
           fim.memory == 0 {
            cell.configureNotEnteredLabelText()
        } else {
            cell.configureNotEnteredLabelTextEmptyString()
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFIMUUID = fimRepository.loadFIM(
            targetPersonUUID: targetPersonUUID!,
            sortedAscending: isSortedAscending
        )[indexPath.row].uuid
        toDetailFIMViewController()
    }

    //　navのボタンへの変更必要か。
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        editingFIMUUID = fimRepository.loadFIM(
            targetPersonUUID: targetPersonUUID!,
            sortedAscending: false
        )[indexPath.row].uuid

        performSegue(withIdentifier: "edit", sender: nil)
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let uuid = fimRepository.loadFIM(
            targetPersonUUID: targetPersonUUID!,
            sortedAscending: isSortedAscending
        )[indexPath.row].uuid else { return }
        fimRepository.removeFIM(fimUUID: uuid)
        tableView.reloadData()
    }
    // MARK: - Method
    private func toDetailFIMViewController() {
        let storyboard = UIStoryboard(name: "DetailFIM", bundle: nil)
        let nextVC =
        storyboard.instantiateViewController(withIdentifier: "detailFIM") as! DetailFIMViewController
        nextVC.fimUUID = selectedFIMUUID
        nextVC.mode = .fim
        navigationController?.pushViewController(nextVC, animated: true)
    }
    // MARK: - View Configue
    private func configueViewNavigationbarColor() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Colors.baseColor
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
    // MARK: - DateFormatter　Date型→String型へ変更
    func dateFormatter(date: Date) -> String {
        let dateFormatter = Foundation.DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateStyle = .medium
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
}
