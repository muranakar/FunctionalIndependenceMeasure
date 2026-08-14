//
//  EditFIMView.swift
//  FunctionalIndependenceMeasure
//
//  保存済みのFIM評価を項目ごとに修正する。
//

import SwiftUI
import SwiftData

struct EditFIMView: View {
    let record: FIMRecord

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var scores: [Int]

    init(record: FIMRecord) {
        self.record = record
        self._scores = State(initialValue: FIMItem.allCases.map { record[$0] })
    }

    var body: some View {
        NavigationStack {
            Form {
                ForEach(FIMCategory.allCases) { category in
                    Section("\(category.rawValue)（\(category.fullScore)点）") {
                        ForEach(category.items) { item in
                            Picker(item.title, selection: binding(for: item)) {
                                Text("未入力").tag(FIMScore.unanswered)
                                ForEach(Array(FIMScore.range), id: \.self) { score in
                                    Text("\(score)点").tag(score)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("評価の編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存", action: save)
                }
            }
        }
    }

    private func binding(for item: FIMItem) -> Binding<Int> {
        Binding(
            get: { scores[item.rawValue] },
            set: { scores[item.rawValue] = $0 }
        )
    }

    private func save() {
        for item in FIMItem.allCases {
            record[item] = scores[item.rawValue]
        }
        record.updatedAt = .now
        // 編集内容を失わないよう自動保存に任せず確実に書き込む
        try? modelContext.save()
        dismiss()
    }
}
