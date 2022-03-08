//
//  FIMPDF.swift
//  FunctionalIndependenceMeasure
//
//  Created by 村中令 on 2022/03/09.
//

import Foundation
import QuickLook

final class FIMPDF {
    private let assessor: Assessor
    private let targetPerson: TargetPerson
    private let fim: FIM

    init(assessor: Assessor,
         targetPerson: TargetPerson,
         fim: FIM) {
        self.assessor = assessor
        self.targetPerson = targetPerson
        self.fim = fim
    }
    /*
     この関数はHTML文字列を受け取り、PDFファイルを表す `NSData` オブジェクトを返します。
     */
    func getPDF(fromHTML: String) -> NSData {
        let renderer = UIPrintPageRenderer()
        let paperSize = CGSize(width: 595.2, height: 841.8)
        let paperFrame = CGRect(origin: .zero, size: paperSize)
        renderer.setValue(paperFrame, forKey: "paperRect")
        renderer.setValue(paperFrame, forKey: "printableRect")
        let formatter = UIMarkupTextPrintFormatter(markupText: fromHTML)
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, [:])
        for pageI in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: pageI, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()
        return pdfData
    }
    /*
     この関数は、特定の `data` をアプリの一時ストレージに保存します。さらに、そのファイルが存在する場所のパスを返します。
     */
    func saveToTempDirectory(data: NSData) -> URL? {
        let tempDirectory = NSURL.fileURL(withPath: NSTemporaryDirectory(), isDirectory: true)
        let fileName = "FIM-" + "\(targetPerson.name)-\(String(describing: fim.createdAt))" + ".pdf"
        let filePath = tempDirectory.appendingPathComponent(fileName)
        do {
            try data.write(to: filePath)
            return filePath
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    // swiftlint:disable:next function_body_length
    func makeHTMLString() -> String {
        // htmlヘッダーを生成します。
        return """
        <!DOCTYPE html>
        <html>
            <head>
                    <title>FIM結果</title>
            <style>
                    table, th, td {
                      border: 1px solid black;
                      border-collapse: collapse;
                    }
            </style>
            <body>
                <h1>\(targetPerson.name)</h1>
                <h2>FIM（Functional　Independence Measure、機能的自立度評価表）</h2>
                <table style="width:100%">
        <tr>
                    <td colspan="2">項目</td>
                    <td colspan="2">点数</td>
                </tr>
                <tr>
                    <td rowspan="6">セルフケア（42点）</td>
                    <td>A　食事（箸・スプーン）</td>
                    <td>1-7点</td>
                    <td>\(fim.eating)</td>
                </tr>
                <tr>
                    <td>B　整容</td>
                    <td>1-7点</td>
                    <td>\(fim.grooming)</td>
                </tr>
                <tr>
                    <td>C　清拭</td>
                    <td>1-7点</td>
                    <td>\(fim.bathing)</td>
                </tr>
                <tr>
                    <td>D　更衣（上半身）</td>
                    <td>1-7点</td>
                    <td>\(fim.dressingUpperBody)</td>
                </tr>
                <tr>
                    <td>E　更衣（下半身）</td>
                    <td>1-7点</td>
                    <td>\(fim.dressingLowerBody)</td>
                </tr>
                <tr>
                    <td>F　トイレ</td>
                    <td>1-7点</td>
                    <td>\(fim.toileting)</td>
                </tr>
                <tr>
                    <td rowspan="2">排泄（14点）</td>
                    <td>G　排尿コントロール</td>
                    <td>1-7点</td>
                    <td>\(fim.bladderManagement)</td>
                </tr>
                <tr>
                    <td>H　排便コントロール</td>
                    <td>1-7点</td>
                    <td>\(fim.bowelManagement)</td>
                </tr>
                <tr>
                    <td rowspan="3">移乗（21点）</td>
                    <td>I　ベッド、椅子、車椅子</td>
                    <td>1-7点</td>
                    <td>\(fim.transfersBedChairWheelchair)</td>
                </tr>
                <tr>
                    <td>J　トイレ</td>
                    <td>1-7点</td>
                    <td>\(fim.transfersToilet)</td>
                </tr>
                <tr>
                    <td>K 浴槽、シャワー</td>
                    <td>1-7点</td>
                    <td>\(fim.transfersBathShower)</td>
                </tr>
                <tr>
                    <td rowspan="2">移動（14点）</td>
                    <td>L　歩行、車椅子</td>
                    <td>1-7点</td>
                    <td>\(fim.walkWheelchair)</td>
                </tr>
                <tr>
                    <td>M　階段</td>
                    <td>1-7点</td>
                    <td>\(fim.stairs)</td>
                </tr>
                <tr>
                    <td rowspan="2">コミュニケーション（14点）</td>
                    <td>N　理解（聴覚、視覚）</td>
                    <td>1-7点</td>
                    <td>\(fim.comprehension)</td>
                </tr>
                <tr>
                    <td>O　表出（音声、非音声）</td>
                    <td>1-7点</td>
                    <td>\(fim.expression)</td>
                </tr>
                <tr>
                    <td rowspan="3">社会認識（21点）</td>
                    <td>P　社会的交流</td>
                    <td>1-7点</td>
                    <td>\(fim.socialInteraction)</td>
                </tr>
                <tr>
                    <td>Q　問題解決</td>
                    <td>1-7点</td>
                    <td>\(fim.problemSolving)</td>
                </tr>
                <tr>
                    <td>R　記憶</td>
                    <td>1-7点</td>
                    <td>\(fim.memory)</td>
                </tr>
                <tr>
                    <td colspan="2">合計</td>
                    <td colspan="2">18 - 126点 \(fim.sumAll)　</td>
                </tr>
                </table>
                </body>
            </html>
        """
    }
}
