//
//  FIMApp.swift
//  FunctionalIndependenceMeasure
//

import SwiftUI
import SwiftData

@main
struct FIMApp: App {
    private let modelContainer: ModelContainer?
    private let storageError: String?

    init() {
        do {
            modelContainer = try ModelContainer(
                for: Assessor.self, TargetPerson.self, FIMRecord.self
            )
            storageError = nil
        } catch {
            // ここで異常終了させるとアプリが二度と開けなくなる。
            // 医療の記録を扱う以上、状況を伝えて次の手を案内する方が良い
            modelContainer = nil
            storageError = error.localizedDescription
        }
    }

    var body: some Scene {
        WindowGroup {
            if let modelContainer {
                RootView()
                    .modelContainer(modelContainer)
            } else {
                StorageErrorView(message: storageError)
            }
        }
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
                "以前のデータを引き継げませんでした",
                isPresented: .init(
                    get: { if case .failed = migrationResult { return true } else { return false } },
                    set: { if !$0 { migrationResult = nil } }
                )
            ) {
                Button("OK") { migrationResult = nil }
            } message: {
                Text("""
                以前の評価データを読み込めませんでした。
                データは端末に残したままなので、消えてはいません。
                お手数ですが、アプリの提供元までお問い合わせください。
                """)
            }
    }
}

// MARK: - StorageErrorView
/// データベースを開けなかったときに出す画面
struct StorageErrorView: View {
    let message: String?

    var body: some View {
        ContentUnavailableView {
            Label("データを開けませんでした", systemImage: "exclamationmark.triangle")
        } description: {
            VStack(spacing: 12) {
                Text("""
                評価データの保存先を開けませんでした。
                一度アプリを終了して、開き直してください。

                解決しない場合、記録が失われる恐れがあるため、
                アプリを削除する前に提供元までお問い合わせください。
                """)
                if let message {
                    Text(message)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
