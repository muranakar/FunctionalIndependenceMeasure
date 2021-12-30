//
//  FIMTableViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit
import Foundation

class FIMTableViewController: UITableViewController {
    //　画面遷移で値を受け取る変数
    var targetPersonUUID: UUID?
    // 画面遷移先へ値を渡す変数
    var selectedFIMUUID: UUID?
    var editingFIMUUID: UUID?

    let fimRepository = FIMRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let targetPersonName =  fimRepository.loadTargetPerson(targetPersonUUID: targetPersonUUID!)?.name else {
            return
        }
        navigationItem.title = "対象者:\(targetPersonName)様"
        tableView.register(UINib(nibName: "FIMTableViewCell", bundle: nil), forCellReuseIdentifier: "FIMTableViewCell")
        tableView.reloadData()
    }

// MARK: - Segue- FIMTableViewController →　InputTargetPersonViewController
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            guard let nav = segue.destination as? UINavigationController else { return }
//            if let editVC = nav.topViewController as? InputFIMViewController {
//                switch segue.identifier ?? "" {
//                case "edit":
//                    editVC.fimUUID = editingFIMUUID
//                default:
//                    break
//                }
//            }
            if let detailFIMVC = nav.topViewController as? DetailFIMViewController {
                switch segue.identifier ?? "" {
                case "detailFIM":
                    detailFIMVC.fimUUID = selectedFIMUUID
                default:
                    break
                }
            }
        }

    // MARK: - Segue- FIMTableViewController ←　InputFIMViewController
    @IBAction private func backToFIMTableViewController(segue: UIStoryboardSegue) { }

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
        let cell = tableView.dequeueReusableCell(withIdentifier: "FIMTableViewCell") as! FIMTableViewCell
        let fim = fimRepository.loadFIM(targetPersonUUID: targetPersonUUID!)[indexPath.row]
        var createdAtString = "--"
        var updateAtString = "--"
        if let createdAt = fim.createdAt {
            createdAtString  = dateFormatter(date: createdAt)
        }
        if let updateAt = fim.updatedAt {
            updateAtString = dateFormatter(date: updateAt)
        }

        cell.configure(
            sumAll: String(fim.sumAll),
            sumMotor: String(fim.sumTheMotorSubscaleIncludes),
            sumCongnition: String(fim.sumTheCognitionSubscaleIncludes),
            createdAt: createdAtString,
            updatedAt: updateAtString)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedFIMUUID = fimRepository.loadFIM(targetPersonUUID: targetPersonUUID!)[indexPath.row].uuid
        performSegue(withIdentifier: "detailFIM", sender: nil)
    }

    //　navのボタンへの変更必要か。
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        editingFIMUUID = fimRepository.loadFIM(targetPersonUUID: targetPersonUUID!)[indexPath.row].uuid

        performSegue(withIdentifier: "edit", sender: nil)
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let uuid = fimRepository.loadFIM(targetPersonUUID: targetPersonUUID!)[indexPath.row].uuid else { return }
        fimRepository.removeFIM(fimUUID: uuid)
        tableView.reloadData()
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
