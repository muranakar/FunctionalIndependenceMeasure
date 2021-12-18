//
//  FunctionSelectionViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit

class FunctionSelectionViewController: UIViewController {

    var targetPersonUUID: UUID?

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
            case "fimTabel":
                FIMTableVC.targetPersonUUID = targetPersonUUID
            default:
                break
            }
        }
    }
    
    @IBAction private func cancel(segue: UIStoryboardSegue) {

    }
}
