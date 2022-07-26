//
//  FunctionSelectionViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit
import StoreKit

final class FunctionSelectionViewController: UIViewController {
    var targetPersonUUID: UUID?
    let fimRepository = FIMRepository()
    @IBOutlet weak private var asssessmentButton: UIButton!
    @IBOutlet weak private var fimListButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let targetPersonName =  fimRepository.loadTargetPerson(targetPersonUUID: targetPersonUUID!)?.name else {
            return
        }
        navigationItem.title = "対象者:　\(targetPersonName)　様"
        configueViewNavigationBarColor()
        configueViewButtonStyle()
    }

    @IBAction private func toAssessmentVC(_ sender: Any) {
        toAssessmentViewController(targetPersonUUID: targetPersonUUID)
    }

    @IBAction private func toFIMTableVC(_ sender: Any) {
        toFIMTableViewController(targetPersonUUID: targetPersonUUID)
    }
    @IBAction private func shareTwitter(_ sender: Any) {
        shareOnTwitter()
    }
    @IBAction private func shareLine(_ sender: Any) {
        shareOnLine()
    }
    @IBAction private func shareOtherApp(_ sender: Any) {
        shareOnOtherApp()
    }
    @IBAction private func review(_ sender: Any) {
        let urlString = URL(string: "https://apps.apple.com/app/id1606480076?action=write-review")
        guard let writeReviewURL = urlString else {
            fatalError("Expected a valid URL")
        }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }

    // MARK: - Segue- FunctionSelectionViewController ← AssessmentViewController
    @IBAction private func backToFunctionSelectionTableViewController(segue: UIStoryboardSegue) {
        let reviewNum = ReviewRepository.processAfterAddReviewNumPulsOneAndSaveReviewNum()
        if reviewNum == 10 || reviewNum == 31 || reviewNum == 50 {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    // MARK: - Method
    private func toAssessmentViewController(targetPersonUUID: UUID?) {
        let storyboard = UIStoryboard(name: "Assessment", bundle: nil)
        let nextVC =
        storyboard.instantiateViewController(withIdentifier: "assessment") as! AssessmentViewController
        nextVC.targetPersonUUID = targetPersonUUID
        navigationController?.pushViewController(nextVC, animated: true)
    }

    private func toFIMTableViewController(targetPersonUUID: UUID?) {
        let storyboard = UIStoryboard(name: "FIMTable", bundle: nil)
        let nextVC =
        storyboard.instantiateViewController(withIdentifier: "fimTable") as! FIMTableViewController
        nextVC.targetPersonUUID = targetPersonUUID
        navigationController?.pushViewController(nextVC, animated: true)
    }

    private func shareOnTwitter() {
        // シェアするテキストを作成
        let text = "ADL評価のFIMを評価することが可能！"
        // swiftlint:disable:next line_length
        let hashTag = " #ADL #FIM #身体機能 #病院 #クリニック #在宅 #リハビリ #理学療法士 #作業療法士 #作業療法士 #介護 #評価 #身体評価   \nhttps://apps.apple.com/jp/app/fim/id1606480076"
        let completedText = text + "\n" + hashTag

        // 作成したテキストをエンコード
        let encodedText = completedText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        // エンコードしたテキストをURLに繋げ、URLを開いてツイート画面を表示させる
        if let encodedText = encodedText,
           let url = URL(string: "https://twitter.com/intent/tweet?text=\(encodedText)") {
            UIApplication.shared.open(url)
        }
    }

    private  func shareOnLine() {
        let urlscheme: String = "https://line.me/R/share?text="
        // swiftlint:disable:next line_length
        let message = "ADL評価のFIMを評価することが可能！ #ADL #FIM #身体機能 #病院 #クリニック #在宅 #リハビリ #理学療法士 #作業療法士 #作業療法士 #介護 #評価 #身体評価   \nhttps://apps.apple.com/jp/app/fim/id1606480076"

        // line:/msg/text/(メッセージ)
        let urlstring = urlscheme + "/" + message

        // URLエンコード
        guard let  encodedURL =
                urlstring.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) else {
            return
        }

        // URL作成
        guard let url = URL(string: encodedURL) else {
            return
        }

        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: { (succes) in
                    //  LINEアプリ表示成功
                })
            } else {
                UIApplication.shared.openURL(url)
            }
        } else {
            // LINEアプリが無い場合
            let alertController = UIAlertController(title: "エラー",
                                                    message: "LINEがインストールされていません",
                                                    preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default))
            present(alertController,animated: true,completion: nil)
        }
    }

    private func shareOnOtherApp() {
        let url = URL(string: "https://sites.google.com/view/muranakar")
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!)
        }
    }

    // MARK: - View Configue
    private func configueViewNavigationBarColor() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "navigation")!
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }

    private func configueViewButtonStyle() {
        asssessmentButton.tintColor = Colors.baseColor
        asssessmentButton.backgroundColor = Colors.mainColor
        asssessmentButton.layer.cornerRadius = 10
        asssessmentButton.layer.shadowOpacity = 0.7
        asssessmentButton.layer.shadowRadius = 3
        asssessmentButton.layer.shadowColor = UIColor.black.cgColor
        asssessmentButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        fimListButton.tintColor = Colors.baseColor
        fimListButton.backgroundColor = Colors.mainColor
        fimListButton.layer.cornerRadius = 10
        fimListButton.layer.shadowOpacity = 0.7
        fimListButton.layer.shadowRadius = 3
        fimListButton.layer.shadowColor = UIColor.black.cgColor
        fimListButton.layer.shadowOffset = CGSize(width: 1, height: 1)
    }
}
