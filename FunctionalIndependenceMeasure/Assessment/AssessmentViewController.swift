//
//  AssessmentViewController.swift
//  Functional Independence Measure
//
//  Created by 村中令 on 2021/12/07.
//

import UIKit

class AssessmentViewController: UIViewController {
    //　画面遷移で値を受け取る変数
    var targetPersonUUID: UUID?
    // 画面遷移先へ値を渡す変数
    var fimUUID: UUID?

    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var button1: UIButton!
    @IBOutlet private weak var button2: UIButton!
    @IBOutlet private weak var button3: UIButton!
    @IBOutlet private weak var button4: UIButton!
    @IBOutlet private weak var button5: UIButton!
    @IBOutlet private weak var button6: UIButton!
    @IBOutlet private weak var button7: UIButton!

    private var fimItemCount = 0
    private var buttons: [UIButton] = []
    private var fimItemText: [String] = []
    private var fimNum = [1, 2, 3, 4, 5, 6, 7]
    private var dictionaryButtonAndString: [UIButton: String] = [:]
    private var dictionaryButtonAndNum: [UIButton: Int] = [:]
    private var assessmentResultFIM: [Int] = []

    let fimRepository = FIMRepository()

    override func viewDidLoad() {
        super.viewDidLoad()
        decoderFimJsonFile()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        label.text = FimData[fimItemCount].fimItem
        textView.text = FimData[fimItemCount].attention
        updateDictionary()
    }

    //　ボタンが選択された際に、そのボタンと関連づけられた文字列を、テキストビューに反映させる。
    @IBAction private func update(sender: UIButton) {
        textView.text = dictionaryButtonAndString[sender]
    }
    //　一つのボタンが押された際、そのボタン以外は非選択状態にする
    @IBAction private func change(sender: UIButton) {
        buttons.forEach { (button: UIButton) in
            button.isSelected = (button === sender)
        }
    }

    @IBAction private func decide(_ sender: Any) {
        fimItemCount += 1
        let button = buttons.filter { $0.isSelected == true }.first
        guard let num = dictionaryButtonAndNum[button!] else { return }
        assessmentResultFIM.append(num)

        if fimItemCount == 18 {
            let fim = createFimFromArrayAssessmentResult()
            fimUUID = fim.uuid
            guard let targetPersonUUID = targetPersonUUID else {
                fatalError("targetPersonUUIDの中身がない。")
            }
            fimRepository.appendFIM(targetPersonUUID: targetPersonUUID, fim: fim)
            performSegue(withIdentifier: "fim", sender: nil)
        } else {
        updateScreenAndUIButtonIsSelectedFalse()
        }
    }

    private func updateDictionary() {
        fimItemText = { () -> [String] in
            let texts = [
                FimData[fimItemCount].one,
                FimData[fimItemCount].two,
                FimData[fimItemCount].three,
                FimData[fimItemCount].four,
                FimData[fimItemCount].five,
                FimData[fimItemCount].six,
                FimData[fimItemCount].seven
            ]
            return texts
        }()
        buttons = [
            button1, button2, button3, button4, button5, button6, button7
        ]
        dictionaryButtonAndString = { [UIButton: String](uniqueKeysWithValues: zip(buttons, fimItemText)) }()
        dictionaryButtonAndNum = { [UIButton: Int](uniqueKeysWithValues: zip(buttons, fimNum))}()
    }

    private func createFimFromArrayAssessmentResult() -> FIM {
        // creatAt updateAtをどのタイミングでいれるか。
        let fim =
        FIM(
            eating: assessmentResultFIM[0],
            grooming: assessmentResultFIM[1],
            bathing: assessmentResultFIM[2],
            dressingUpperBody: assessmentResultFIM[3],
            dressingLowerBody: assessmentResultFIM[4],
            toileting: assessmentResultFIM[5],
            bladderManagement: assessmentResultFIM[6],
            bowelManagement: assessmentResultFIM[7],
            transfersBedChairWheelchair: assessmentResultFIM[8],
            transfersToilet: assessmentResultFIM[9],
            transfersBathShower: assessmentResultFIM[10],
            walkWheelchair: assessmentResultFIM[11],
            stairs: assessmentResultFIM[12],
            comprehension: assessmentResultFIM[13],
            expression: assessmentResultFIM[14],
            socialInteraction: assessmentResultFIM[15],
            problemSolving: assessmentResultFIM[16],
            memory: assessmentResultFIM[17]
        )
        return fim
    }

    private func updateScreenAndUIButtonIsSelectedFalse() {
        viewWillAppear(true)
        buttons.forEach { (button: UIButton) in
            button.isSelected = false
        }
    }
    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nav = segue.destination as? UINavigationController else { return }
        if let fimVC = nav.topViewController as? FIMViewController {
            switch segue.identifier ?? "" {
            case "fim":
                fimVC.fimUUID = fimUUID
            default:
                break
            }
        }
    }

    // MARK: - JSONファイルのデコーダー
    private var FimData:[FimItem] = []

    struct FimItem: Codable {
        var fimItem: String
        var seven: String
        var six: String
        var five: String
        var four: String
        var three: String
        var two: String
        var one: String
        var attention: String
    }

    private func decoderFimJsonFile() {
        let data: Data?
        guard let file = Bundle.main.url(forResource: "FIM", withExtension: "json") else {
            fatalError("ファイルが見つかりません")
        }

        do {
            data  = try? Data(contentsOf: file)
        } catch {
            fatalError("ファイルをロード不可")
        }

        do {
            guard let data = data else {
                print("アンラップ失敗")
                return
            }
            let decoder = JSONDecoder()
            FimData = try decoder.decode([FimItem].self, from: data)
        } catch {
            fatalError("パース不可")
        }
    }
}
