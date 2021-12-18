//
//  InputTargetPersonViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit

class InputTargetPersonViewController: UIViewController {

    enum Mode {
        case input
        case edit(UUID?)
    }

    var mode: Mode?
    let fimRepository = FIMRepository()
    var assessorUUID: UUID?
    private (set) var editingTargetPersonUUID: UUID?
    private (set) var targetPerson: TargetPerson?
    @IBOutlet weak private var targetPersonNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let mode = mode else {
            fatalError("mode is nil.")
        }

        // MARK: -テキストフィールドに名前を設定
        targetPersonNameTextField.text = {
            switch mode {
            case .input:
                return ""
            case let .edit(editingTargetPersonUUID):
                guard let editingTargetPersonUUID = editingTargetPersonUUID else {
                    fatalError("editingAssessorUUID is nil")
                    return nil
                }
                let targetPersonName = fimRepository.loadTargetPerson(targetPersonUUID: editingTargetPersonUUID)?.name
                return targetPersonName
            }
        }()
    }

    @IBAction private func saveAction(_ sender: Any) {
        guard let mode = mode else { return }

        switch mode {
        case .input:
            let newTargetPerson = TargetPerson()
            newTargetPerson.name = targetPersonNameTextField.text ?? ""
            fimRepository.appendTargetPerson(assessorUUID: assessorUUID!, targetPerson: newTargetPerson)
            
        case let .edit(editingTargetPersonUUID):
            guard let editingTargetPersonUUID = editingTargetPersonUUID else {
                return
            }

            let editingTargetPersonName = targetPersonNameTextField.text ?? ""
            fimRepository.updateTargetPerson(
                uuid: editingTargetPersonUUID,
                name: editingTargetPersonName
            )
        }

        performSegue(
            withIdentifier: "save",
            sender: sender
        )
    }
}
