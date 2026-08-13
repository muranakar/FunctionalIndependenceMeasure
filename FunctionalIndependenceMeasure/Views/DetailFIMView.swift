//
//  DetailFIMView.swift
//  FunctionalIndependenceMeasure
//
//  1回分のFIM評価の内訳。
//

import SwiftUI
import QuickLook

struct DetailFIMView: View {
    let record: FIMRecord

    @State private var isEditing = false
    @State private var isShowingCopyCompleted = false
    @State private var pdfURL: URL?

    var body: some View {
        List {
            Section {
                summaryRow(title: "総合計", score: record.total, fullScore: FIMScore.fullScore, isEmphasized: true)
                summaryRow(title: "運動項目合計", score: record.motorSubtotal, fullScore: FIMScore.motorFullScore)
                summaryRow(title: "認知項目合計", score: record.cognitionSubtotal, fullScore: FIMScore.cognitionFullScore)

                if record.hasUnansweredItem {
                    Label("未入力の項目が\(record.unansweredItems.count)件あります", systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            } header: {
                Text("評価日:　\(DateFormatter.evaluated.string(from: record.createdAt))")
            } footer: {
                if let updatedAt = record.updatedAt {
                    Text("最終更新:　\(DateFormatter.evaluated.string(from: updatedAt))")
                }
            }

            ForEach(FIMCategory.allCases) { category in
                Section("\(category.rawValue)（\(category.fullScore)点）") {
                    ForEach(category.items) { item in
                        HStack {
                            Text(item.title)
                            Spacer()
                            Text(record.displayScore(for: item))
                                .foregroundStyle(record[item] == FIMScore.unanswered ? .secondary : .primary)
                        }
                    }
                }
            }

            Section {
                Button {
                    UIPasteboard.general.string = FIMResultFormatter.string(from: record)
                    isShowingCopyCompleted = true
                } label: {
                    Label("評価結果をコピーする", systemImage: "doc.on.doc")
                }
                Button {
                    pdfURL = FIMPDFRenderer.writeToTemporaryDirectory(for: record)
                } label: {
                    Label("PDFで出力する", systemImage: "doc.richtext")
                }
            }
        }
        .navigationTitle("評価結果")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("編集") { isEditing = true }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditFIMView(record: record)
        }
        .quickLookPreview($pdfURL)
        .alert("コピー完了", isPresented: $isShowingCopyCompleted) {
            Button("OK") {}
        } message: {
            Text("FIMデータ内容のコピーが\n完了しました。")
        }
    }

    private func summaryRow(title: String, score: Int, fullScore: Int, isEmphasized: Bool = false) -> some View {
        HStack {
            Text(title)
                .font(isEmphasized ? .headline : .body)
            Spacer()
            Text("\(score) / \(fullScore) 点")
                .font(isEmphasized ? .title3 : .body)
                .fontWeight(isEmphasized ? .bold : .regular)
                .foregroundStyle(isEmphasized ? Theme.main : .secondary)
        }
    }
}
