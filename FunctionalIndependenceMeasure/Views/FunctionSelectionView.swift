//
//  FunctionSelectionView.swift
//  FunctionalIndependenceMeasure
//
//  対象者を選んだあとの機能選択画面。
//

import SwiftUI
import StoreKit

struct FunctionSelectionView: View {
    let targetPerson: TargetPerson

    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        List {
            Section("FIM") {
                NavigationLink(value: Route.newAssessment(targetPerson)) {
                    Label("評価する", systemImage: "square.and.pencil")
                }
                NavigationLink(value: Route.fimRecords(targetPerson)) {
                    Label("評価一覧をみる", systemImage: "list.bullet.rectangle")
                }
            }

            Section("このアプリについて") {
                Button {
                    if let url = AppLinks.xShareURL { openURL(url) }
                } label: {
                    Label("Xで共有する", systemImage: "square.and.arrow.up")
                }
                Button {
                    if let url = AppLinks.lineShareURL { openURL(url) }
                } label: {
                    Label("LINEで共有する", systemImage: "bubble.left.and.bubble.right")
                }
                Button {
                    openURL(AppLinks.reviewURL)
                } label: {
                    Label("レビューを書く", systemImage: "star")
                }
                Button {
                    openURL(AppLinks.developerSiteURL)
                } label: {
                    Label("他のアプリをみる", systemImage: "app.badge")
                }
            }
        }
        .navigationTitle("対象者:　\(targetPerson.name)　様")
        .navigationBarTitleDisplayMode(.inline)
        .task {  // 画面に戻るたびに動く
            // 評価を終えて結果を閉じ、この画面に戻ってから少し待って出す（結果の確認中や dismiss と同時には出さない）
            guard ReviewCounter.consumePendingRequest() else { return }
            try? await Task.sleep(for: .seconds(0.8))
            guard !Task.isCancelled else { return }
            requestReview()
        }
    }
}
