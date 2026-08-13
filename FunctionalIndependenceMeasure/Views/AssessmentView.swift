//
//  AssessmentView.swift
//  FunctionalIndependenceMeasure
//
//  FIMの18項目を順に評価する画面。採点基準は FIM.json から読み込む。
//

import SwiftUI
import SwiftData
import StoreKit

struct AssessmentView: View {
    let targetPerson: TargetPerson

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview

    @State private var criteria: [FIMScoringCriteria] = []
    @State private var currentIndex = 0
    @State private var scores: [Int] = []
    @State private var selectedScore: Int?
    @State private var isShowingAttention = true
    @State private var isConfirmingCancel = false
    @State private var isShowingUnselectedAlert = false
    @State private var completedRecord: FIMRecord?

    private var currentItem: FIMItem? {
        FIMItem.allCases.indices.contains(currentIndex) ? FIMItem.allCases[currentIndex] : nil
    }

    private var currentCriteria: FIMScoringCriteria? {
        criteria.indices.contains(currentIndex) ? criteria[currentIndex] : nil
    }

    var body: some View {
        Group {
            if let item = currentItem, let criteria = currentCriteria {
                assessmentBody(item: item, criteria: criteria)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("対象者:　\(targetPerson.name)　様")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("中止") { isConfirmingCancel = true }
            }
        }
        .task {
            if criteria.isEmpty {
                criteria = FIMScoringCriteria.loadAll()
            }
        }
        .sheet(item: $completedRecord) { record in
            NavigationStack {
                DetailFIMView(record: record)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("完了") {
                                completedRecord = nil
                                dismiss()
                            }
                        }
                    }
            }
        }
        .alert("評価中止", isPresented: $isConfirmingCancel) {
            Button("中止する", role: .destructive) { dismiss() }
            Button("中止しない", role: .cancel) {}
        } message: {
            Text("今回の入力データは途中保存されません。\n評価を中止しますか？")
        }
        .alert("未選択", isPresented: $isShowingUnselectedAlert) {
            Button("OK") {}
        } message: {
            Text("いずれかの点数を選択してから、\n決定ボタンを押してください")
        }
    }

    // MARK: - 評価入力

    private func assessmentBody(item: FIMItem, criteria: FIMScoringCriteria) -> some View {
        VStack(spacing: 0) {
            header(item: item)

            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    descriptionBox(criteria: criteria)

                    ForEach(Array(FIMScore.range), id: \.self) { score in
                        scoreButton(score: score, criteria: criteria)
                    }
                }
                .padding()
            }

            footer()
        }
    }

    private func header(item: FIMItem) -> some View {
        VStack(spacing: 8) {
            ProgressView(value: Double(currentIndex + 1), total: Double(FIMItem.allCases.count))
                .tint(Theme.main)

            HStack {
                Text("\(currentIndex + 1)/\(FIMItem.allCases.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(item.title)
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Button {
                    selectedScore = nil
                    isShowingAttention = true
                } label: {
                    Label("注意点", systemImage: "exclamationmark.circle")
                        .labelStyle(.titleAndIcon)
                }
                .tint(.red)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    /// 選択中の点数の採点基準、未選択のときは注意点を表示する
    private func descriptionBox(criteria: FIMScoringCriteria) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            if let selectedScore {
                Text("\(selectedScore)点")
                    .font(.caption)
                    .foregroundStyle(Theme.main)
                Text(criteria.description(for: selectedScore))
            } else if isShowingAttention {
                Text(criteria.attention)
            }
        }
        .font(.callout)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .topLeading)
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func scoreButton(score: Int, criteria: FIMScoringCriteria) -> some View {
        Button {
            selectedScore = score
            isShowingAttention = false
        } label: {
            HStack {
                Text("\(score)点")
                    .fontWeight(.bold)
                Spacer()
                Text(criteria.description(for: score))
                    .font(.caption)
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .tint(selectedScore == score ? Theme.main : Color.secondary)
    }

    private func footer() -> some View {
        HStack(spacing: 12) {
            if currentIndex >= 1 {
                Button {
                    goBackOneItem()
                } label: {
                    Label("戻る", systemImage: "chevron.left")
                }
                .buttonStyle(.bordered)
            }

            Button("スキップ") { advance(with: FIMScore.unanswered) }
                .buttonStyle(.bordered)

            Button {
                guard let selectedScore else {
                    isShowingUnselectedAlert = true
                    return
                }
                advance(with: selectedScore)
            } label: {
                Text("決定")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Theme.main)
        }
        .controlSize(.large)
        .padding()
    }

    // MARK: - 操作

    private func advance(with score: Int) {
        scores.append(score)
        selectedScore = nil
        isShowingAttention = true

        guard scores.count == FIMItem.allCases.count else {
            currentIndex += 1
            return
        }
        save()
    }

    private func goBackOneItem() {
        guard currentIndex >= 1 else { return }
        currentIndex -= 1
        if !scores.isEmpty {
            scores.removeLast()
        }
        selectedScore = nil
        isShowingAttention = true
    }

    private func save() {
        let record = FIMRecord(scores: scores)
        modelContext.insert(record)
        record.targetPerson = targetPerson
        // 評価記録は失うと再入力が必要になるため、自動保存に任せず確実に書き込む
        try? modelContext.save()
        completedRecord = record

        if ReviewCounter.incrementAndShouldRequestReview() {
            requestReview()
        }
    }
}
