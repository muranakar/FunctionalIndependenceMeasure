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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        cell.configure(
            fim: fim,
            createdAt: createdAtString,
            updatedAt: updateAtString,
            copyFIMTextHandler: {
                UIPasteboard.general.string = CopyAndPasteFunction(
                    assessor: assessor,
                    targetPerson: targetPerson,
                    fim: fim,
                    createdAtString: createdAtString
                ).copyAndPasteString
                // MARK: - weak selfを行うべきなのか、そうではないのか。
                self.copyButtonPushAlert(title: "コピー完了", message: "FIMデータ内容のコピーが\n完了しました。")
            })

        // fimの項目の中に、未入力があると、未入力ラベルが表示される。
        if fim.eating == 0 || fim.grooming == 0 || fim.bathing == 0 || fim.dressingUpperBody == 0 ||
            fim.dressingLowerBody == 0 || fim.toileting == 0 || fim.bladderManagement == 0 ||
            fim.bowelManagement == 0 || fim.transfersBedChairWheelchair == 0 ||
            fim.transfersToilet == 0 || fim.transfersBathShower == 0 ||
            fim.walkWheelchair == 0 || fim.stairs == 0 ||
            fim.comprehension == 0 || fim.expression == 0 ||
            fim.socialInteraction == 0 || fim.problemSolving == 0 ||
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
    // MARK: - UIAlertController
    func copyButtonPushAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
