//
//  FIMApp.swift
//  FunctionalIndependenceMeasure
//

import SwiftUI
import SwiftData

@main
struct FIMApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(
                for: Assessor.self, TargetPerson.self, FIMRecord.self
            )
        } catch {
            fatalError("SwiftDataの初期化に失敗しました: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(modelContainer)
    }
}

// MARK: - RootView
struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var migrationResult: RealmMigrationResult?

    var body: some View {
        AssessorListView()
            .task {
                // 旧バージョンのRealmデータがあれば初回起動時に引き継ぐ
                migrationResult = RealmToSwiftDataMigrator.migrateIfNeeded(context: modelContext)
            }
            .alert(
                "データの引き継ぎに失敗しました",
                isPresented: .init(
                    get: { if case .failed = migrationResult { return true } else { return false } },
                    set: { if !$0 { migrationResult = nil } }
                )
            ) {
                Button("OK") { migrationResult = nil }
            } message: {
                Text("以前の評価データを読み込めませんでした。データは削除されていません。次回起動時に再度引き継ぎを試みます。")
            }
    }
}
