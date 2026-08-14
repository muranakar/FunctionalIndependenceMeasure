//
//  FIMPDFRenderer.swift
//  FunctionalIndependenceMeasure
//
//  評価結果をA4のPDFへ書き出す。表のレイアウトは旧バージョンを踏襲している。
//

import UIKit

enum FIMPDFRenderer {

    /// PDFを一時ディレクトリへ書き出し、そのURLを返す
    static func writeToTemporaryDirectory(for record: FIMRecord) -> URL? {
        let targetPersonName = record.targetPerson?.name ?? "対象者"
        let createdAt = DateFormatter.pdfDate.string(from: record.createdAt)
        let fileName = "FIM-\(targetPersonName)-\(createdAt).pdf"

        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try pdfData(for: record).write(to: url)
            return url
        } catch {
            assertionFailure("PDFの書き出しに失敗しました: \(error)")
            return nil
        }
    }

    // MARK: - PDF生成

    private static func pdfData(for record: FIMRecord) -> Data {
        let renderer = UIPrintPageRenderer()
        // A4
        let paperFrame = CGRect(origin: .zero, size: CGSize(width: 595.2, height: 841.8))
        renderer.setValue(paperFrame, forKey: "paperRect")
        renderer.setValue(paperFrame, forKey: "printableRect")

        let formatter = UIMarkupTextPrintFormatter(markupText: html(for: record))
        renderer.addPrintFormatter(formatter, startingAtPageAt: 0)

        let data = NSMutableData()
        UIGraphicsBeginPDFContextToData(data, .zero, [:])
        for page in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: page, in: UIGraphicsGetPDFContextBounds())
        }
        UIGraphicsEndPDFContext()
        return data as Data
    }

    private static func html(for record: FIMRecord) -> String {
        let targetPersonName = record.targetPerson?.name ?? "-"
        let createdAt = DateFormatter.pdfDate.string(from: record.createdAt)

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
        </head>
        <body>
            <h1>\(escaped(targetPersonName))　様</h1>
            <h2 style="text-align:right">　作成日　\(createdAt)</h2>
            <h2>FIM（Functional　Independence Measure、機能的自立度評価表）</h2>
            <table style="width:100%">
                <tr>
                    <td colspan="2">項目</td>
                    <td colspan="2">点数</td>
                </tr>
        \(categoryRows(for: record))
                <tr>
                    <td colspan="2">合計</td>
                    <td>\(FIMItem.allCases.count) - \(FIMScore.fullScore)点</td>
                    <td>\(record.total)</td>
                </tr>
            </table>
        </body>
        </html>
        """
    }

    /// 大項目ごとに rowspan でまとめた行を生成する
    private static func categoryRows(for record: FIMRecord) -> String {
        FIMCategory.allCases.map { category in
            let items = category.items
            return items.enumerated().map { index, item in
                let categoryCell = index == 0
                    ? "            <td rowspan=\"\(items.count)\">\(category.rawValue)（\(category.fullScore)点）</td>\n"
                    : ""
                return """
                        <tr>
                \(categoryCell)            <td>\(escaped(item.pdfTitle))</td>
                            <td>\(FIMScore.min)-\(FIMScore.max)点</td>
                            <td>\(record.displayScore(for: item))</td>
                        </tr>
                """
            }.joined(separator: "\n")
        }.joined(separator: "\n")
    }

    /// 対象者名などがHTMLを壊さないようにエスケープする
    private static func escaped(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
    }
}
