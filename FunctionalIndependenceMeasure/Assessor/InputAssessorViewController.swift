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
    let fimRepository = FIMRepository()
    private (set) var editingAssessorUUID: UUID?
    private (set) var assessor: Assessor?
    @IBOutlet weak private var assessorNameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let mode = mode else {
            fatalError("mode is nil.")
        }

        assessorNameTextField.text = {
            switch mode {
            case .input:
                return ""
            case let .edit(editingAssessorUUID):
                guard let editingAssessorUUID = editingAssessorUUID else {
                    fatalError("editingAssessorUUID is nil")
                    return nil
                }
                let assesorName = fimRepository.loadAssessor(assessorUUID: editingAssessorUUID)?.name
                return assesorName
            }
        }()
    }

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
            let assessor = fimRepository.loadAssessor(assessorUUID: editingAssessorUUID)
            let editAssessorName = assessorNameTextField.text ?? ""
//            nameプロパティを引数に入れて、トランザクションの中にいれるべきでは？
//            fimRepository.updateAssessor(assessor: <#T##Assessor#>)
        }

        performSegue(
            withIdentifier: {
                switch mode {
                case .edit:
                    return "edit"
                case .input:
                    return "save"
                }
            }(),
            sender: sender
        )
    }
}
