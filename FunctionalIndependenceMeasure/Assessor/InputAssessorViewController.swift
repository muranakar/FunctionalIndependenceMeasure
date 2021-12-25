//
//  InputAssessorViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit

class InputAssessorViewController: UIViewController {
    enum Mode {
        case input
        case edit(UUID?)
    }
    var mode: Mode?
    private let fimRepository = FIMRepository()
    private (set) var editingAssessorUUID: UUID?
    private (set) var assessor: Assessor?
    @IBOutlet weak private var assessorNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let mode = mode else {
            fatalError("mode の中身が入っていない")
        }
        assessorNameTextField.text = {
            switch mode {
            case .input:
                return ""
            case let .edit(editingAssessorUUID):
                guard let editingAssessorUUID = editingAssessorUUID else {
                    fatalError("editingAssessorUUID の中身が入っていない")
                }
                let assesorName =
                fimRepository.loadAssessor(assessorUUID: editingAssessorUUID)?.name
                return assesorName
            }
        }()
    }

// MARK: - 評価者データを保存するUIButtonのIBAction
    @IBAction private func saveAction(_ sender: Any) {
        guard let mode = mode else { return }

        switch mode {
        case .input:
            let newAssessor = Assessor()
            newAssessor.name = assessorNameTextField.text ?? ""
            fimRepository.apppendAssessor(assesor: newAssessor)
        case let .edit(editingAssessorUUID):
            guard let editingAssessorUUID = editingAssessorUUID else {
                return
            }
            let editAssessorName = assessorNameTextField.text ?? ""
            fimRepository.updateAssessor(
                uuid: editingAssessorUUID,
                name: editAssessorName)
        }

        performSegue(
            withIdentifier: "save",
            sender: sender
        )
    }
}
