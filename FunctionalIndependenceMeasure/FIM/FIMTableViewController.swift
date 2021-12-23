//
//  FIMTableViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit

class FIMTableViewController: UITableViewController {
    //　画面遷移で値を受け取る変数
    var targetPersonUUID: UUID?
    // 画面遷移先へ値を渡す変数
    var selectedFIMUUID: UUID?
    var editingFIMUUID: UUID?

    let fimRepository = FIMRepository()

    override func viewDidLoad() {
        tableView.reloadData()
    }

    // MARK: - Segue- TargetPersonTableViewController →　InputTargetPersonViewController
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let nav = segue.destination as? UINavigationController else { return }
//        if let inputVC = nav.topViewController as? InputFIMViewController {
//            switch segue.identifier ?? "" {
//            case "input":
//                inputVC.mode = .input
//                inputVC.assessorUUID = assessorUUID
//            case "edit":
//                guard let editingTargetPersonUUID = editingTargetPersonUUID else {
//                    return
//                }
//                inputVC.mode = .edit(editingTargetPersonUUID)
//                inputVC.assessorUUID = assessorUUID
//            default:
//                break
//            }
//        }
//        if let nextVC = nav.topViewController as? FIMViewController {
//            switch segue.identifier ?? "" {
//            case "next":
//                nextVC.targetPersonUUID = selectedTargetPersonUUID
//            default:
//                break
//            }
//        }
//
//    }

    @IBAction private func input(_ sender: Any) {
        performSegue(withIdentifier: "input", sender: nil)
    }

    // MARK: - Segue- FIMTableViewController ←　InputFIMViewController
    @IBAction private func cancel(segue: UIStoryboardSegue) { }

    @IBAction private func save(segue: UIStoryboardSegue) {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fimRepository.loadFIM(targetPersonUUID: targetPersonUUID!).count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // swiftlint:disable:next force_cast
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! FIMTableViewCell
        let fim = fimRepository.loadFIM(targetPersonUUID: targetPersonUUID!)[indexPath.row]
        // 詳細の設定を入れていく。
        // cell.configue(name: tagetPerson.name)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFIMUUID = fimRepository.loadFIM(targetPersonUUID: targetPersonUUID!)[indexPath.row].uuid
        //        segueを設定する。
        //        performSegue(withIdentifier: "next", sender: nil)
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        editingFIMUUID = fimRepository.loadFIM(targetPersonUUID: targetPersonUUID!)[indexPath.row].uuid
        //        segueを設定する。
        //        performSegue(withIdentifier: "edit", sender: nil)
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let uuid = fimRepository.loadFIM(targetPersonUUID: targetPersonUUID!)[indexPath.row].uuid else { return }
        fimRepository.removeFIM(fimUUID: uuid)
        tableView.reloadData()
    }
}
