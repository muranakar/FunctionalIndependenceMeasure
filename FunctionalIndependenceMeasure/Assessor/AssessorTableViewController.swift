//
//  AssessorTableViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit

class AssessorTableViewController: UITableViewController {

    var nextAssessorUUID: UUID?
    var editingAssessorUUID: UUID?
    let fimRepository = FIMRepository()
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    // MARK: - Segue- AssessorTableViewController →　inputAccessoryViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nav = segue.destination as? UINavigationController else { return }
        guard let inputVC = nav.topViewController as? InputAssessorViewController else { return }
//        guard let nextVC = nav.topViewController as? TargetPersonTableViewController else { return }

        switch segue.identifier ?? "" {
//        case "next":
//            nextVC.AssessorUUID = nextAssessorUUID
//
        case "input":
            inputVC.mode = .input
        case "edit":
            guard let editingAssessorUUID = editingAssessorUUID else {
                return
            }
            inputVC.mode = .edit(editingAssessorUUID)
            
        default:
            break
        }
    }


    @IBAction func input(_ sender: Any) {
        performSegue(withIdentifier: "input", sender: nil)
    }

    // MARK: - Segue- AssessorTableViewController ←　inputAccessoryViewController
    @IBAction private func cancel(segue: UIStoryboardSegue) { }

    @IBAction private func save(segue: UIStoryboardSegue) {
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fimRepository.loadAssessor().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! AssessorTableViewCell
        let assessor = fimRepository.loadAssessor()[indexPath.row]
        cell.configue(assessor: assessor)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        nextAssessorUUID = fimRepository.loadAssessor()[indexPath.row].uuid
        performSegue(withIdentifier: "next", sender: nil)
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        editingAssessorUUID = fimRepository.loadAssessor()[indexPath.row].uuid
        performSegue(withIdentifier: "edit", sender: nil)
    }

    override func tableView(_ tableView: UITableView,
                            commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        guard let uuid = fimRepository.loadAssessor()[indexPath.row].uuid else { return }
        fimRepository.removeAssessor(uuid: uuid)
        tableView.reloadData()
    }
}
