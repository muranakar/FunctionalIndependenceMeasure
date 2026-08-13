//
//  FIMRecordListView.swift
//  FunctionalIndependenceMeasure
//
//  対象者ごとのFIM評価一覧。
//

import SwiftUI
import SwiftData
import QuickLook

struct FIMRecordListView: View {
    let targetPerson: TargetPerson

    @Environment(\.modelContext) private var modelContext
    @State private var isAscending = false
    @State private var isShowingCopyCompleted = false
    @State private var pdfURL: URL?

    private var records: [FIMRecord] {
        targetPerson.fimRecords.sorted {
            isAscending ? $0.createdAt < $1.createdAt : $0.createdAt > $1.createdAt
        }
    }

    var body: some View {
        Group {
            if records.isEmpty {
                ContentUnavailableView {
                    Label("評価結果がありません", systemImage: "list.bullet.rectangle")
                } description: {
                    Text("「評価する」から評価を行うと、ここに履歴が表示されます。")
                }
            } else {
                recordList
            }
        }
        .navigationTitle("対象者:　\(targetPerson.name)　様")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isAscending.toggle()
                } label: {
                    Label(
                        isAscending ? "古い順" : "新しい順",
                        systemImage: isAscending ? "arrow.up" : "arrow.down"
                    )
                }
            }
        }
        .quickLookPreview($pdfURL)
        .alert("コピー完了", isPresented: $isShowingCopyCompleted) {
            Button("OK") {}
        } message: {
            Text("FIMデータ内容のコピーが\n完了しました。")
        }
    }

    private var recordList: some View {
        List {
            ForEach(records) { record in
                NavigationLink(value: Route.fimDetail(record)) {
                    row(record)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        modelContext.delete(record)
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                    Button {
                        UIPasteboard.general.string = FIMResultFormatter.string(from: record)
                        isShowingCopyCompleted = true
                    } label: {
                        Label("コピー", systemImage: "doc.on.doc")
                    }
                    .tint(Theme.main)
                    Button {
                        pdfURL = FIMPDFRenderer.writeToTemporaryDirectory(for: record)
                    } label: {
                        Label("PDF", systemImage: "doc.richtext")
                    }
                    .tint(Theme.darkBlue)
                }
            }
        }
    }

    private func row(_ record: FIMRecord) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("\(record.total) / \(FIMScore.fullScore) 点")
                    .font(.headline)
                    .foregroundStyle(Theme.main)
                if record.hasUnansweredItem {
                    Text("未入力あり")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
            Text("運動 \(record.motorSubtotal)　認知 \(record.cognitionSubtotal)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("評価日 \(DateFormatter.evaluated.string(from: record.createdAt))")
                .font(.caption2)
                .foregroundStyle(.secondary)
            if let updatedAt = record.updatedAt {
                Text("更新日 \(DateFormatter.evaluated.string(from: updatedAt))")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
