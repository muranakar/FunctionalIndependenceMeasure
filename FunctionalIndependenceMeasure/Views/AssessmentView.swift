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
        // 対象者名が長いとナビゲーションバーで省略されるため、名前は画面内に置く
        .navigationTitle("FIM 評価")
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
                                // 評価の途中や結果確認中に割り込まないよう、閉じるときに依頼する
                                if ReviewCounter.incrementAndShouldRequestReview() {
                                    requestReview()
                                }
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

                    ForEach(Array(FIMScore.range).reversed(), id: \.self) { score in
                        scoreButton(score: score, criteria: criteria)
                    }
                }
                .padding()
            }
            // 項目が変わったらスクロール位置を先頭に戻す。
            // 戻さないと、前の項目でスクロールした位置のままになり項目名が画面外になる
            .id(currentIndex)

            footer()
        }
    }

    private func header(item: FIMItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("対象者:　\(targetPerson.name)　様")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer()
                Text("\(currentIndex + 1) / \(FIMItem.allCases.count)")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.main)
                    .monospacedDigit()
            }

            ProgressView(value: Double(currentIndex + 1), total: Double(FIMItem.allCases.count))
                .tint(Theme.main)

            HStack {
                Text(item.title)
                    .font(.title3)
                    .fontWeight(.bold)
                Text(item.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    // 選択は消さずに開閉だけ切り替える。見比べてから決められるようにする
                    isShowingAttention.toggle()
                } label: {
                    Label("注意点", systemImage: isShowingAttention ? "chevron.up" : "exclamationmark.circle")
                        .labelStyle(.titleAndIcon)
                        .font(.subheadline)
                }
                .tint(.red)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }

    /// 注意点。中身が無い項目では枠ごと出さない（空の箱が居座って選択肢が押し下げられるため）
    @ViewBuilder
    private func descriptionBox(criteria: FIMScoringCriteria) -> some View {
        let attention = criteria.attention.trimmingCharacters(in: .whitespacesAndNewlines)
        // 「ーー注意点ーー」の見出しだけで中身が無い項目があるので、その場合は表示しない
        let hasContent = !attention.isEmpty && attention.replacingOccurrences(of: "ー", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines) != "注意点"

        if isShowingAttention && hasContent {
            Text(attention)
                .font(.callout)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func scoreButton(score: Int, criteria: FIMScoringCriteria) -> some View {
        let isSelected = selectedScore == score
        let description = criteria.description(for: score)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return Button {
            selectedScore = score
        } label: {
            HStack(alignment: .top, spacing: 12) {
                Text("\(score)")
                    .font(.title3.weight(.bold))
                    .frame(width: 28)
                    .monospacedDigit()

                // 採点基準は判断の根拠になるため省略せずに全文を出す
                Text(description)
                    .font(.callout)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
        .tint(isSelected ? Theme.main : Color.secondary)
        .accessibilityLabel("\(score)点。\(description)")
        // 採点基準の文章がラベルに含まれて特定しづらいため、テスト用の識別子を付けている
        .accessibilityIdentifier("score-\(score)")
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
    }
}
