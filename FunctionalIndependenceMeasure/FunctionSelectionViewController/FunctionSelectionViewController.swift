//
//  FunctionSelectionViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit

class FunctionSelectionViewController: UIViewController {
    var targetPersonUUID: UUID?
    let fimRepository = FIMRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let targetPersonName =  fimRepository.loadTargetPerson(targetPersonUUID: targetPersonUUID!)?.name else {
            return
        }
        navigationItem.title = "対象者:\(targetPersonName)様"
        configueColor()
    }
    // MARK: - Segue- FunctionSelectionTableViewController → AssessmentViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nav = segue.destination as? UINavigationController else { return }
        if let assessmentVC = nav.topViewController as? AssessmentViewController {
            switch segue.identifier ?? "" {
            case "assessment":
                assessmentVC.targetPersonUUID = targetPersonUUID
            default:
                break
            }
        }

        if let FIMTableVC = nav.topViewController as? FIMTableViewController {
            switch segue.identifier ?? "" {
            case "fimTable":
                FIMTableVC.targetPersonUUID = targetPersonUUID
            default:
                break
            }
        }
    }

    // MARK: - Segue- FunctionSelectionTableViewController ← AssessmentViewController
    @IBAction private func backToFunctionSelectionTableViewController(segue: UIStoryboardSegue) {
    }

    // MARK: - View Configue
    private func configueColor() {
        let appearance = UINavigationBarAppearance()
               appearance.configureWithOpaqueBackground()
               appearance.backgroundColor = Colors.base1Color
               navigationItem.standardAppearance = appearance
               navigationItem.scrollEdgeAppearance = appearance
               navigationItem.compactAppearance = appearance
    }
}
