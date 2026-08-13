//
//  RealmToSwiftDataMigrator.swift
//  FunctionalIndependenceMeasure
//
//  旧バージョンの Realm データを SwiftData へ一度だけ移し替える。
//  ・元ファイルは複製してから読むため、移行が失敗しても元データは壊れない
//  ・移行が完了するまで退避（リネーム）は行わない
//  ・退避であって削除ではないので、万一のとき手動で復旧できる
//

import Foundation
import RealmSwift
import SwiftData

// MARK: - MigrationResult
enum RealmMigrationResult: Equatable {
    /// 移行済み、または移行対象のRealmファイルが無い
    case notNeeded
    /// 移行完了（評価者数・対象者数・FIM評価数）
    case completed(assessors: Int, targetPersons: Int, fimRecords: Int)
    /// 移行失敗。Realmファイルは退避せずそのまま残している
    case failed(String)
}

// MARK: - RealmToSwiftDataMigrator
enum RealmToSwiftDataMigrator {

    /// 移行完了フラグ。バージョンを付けているのは将来スキーマが変わった場合に区別するため
    private static let didMigrateKey = "didMigrateRealmToSwiftData_v1"

    /// 既定の Realm ファイル URL（旧アプリは既定パスをそのまま使用していた）
    private static var legacyRealmURL: URL? {
        try? FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("default.realm")
    }

    /// 必要であれば移行する。アプリ起動時に一度だけ呼ぶ。
    @MainActor
    @discardableResult
    static func migrateIfNeeded(context: ModelContext) -> RealmMigrationResult {
        guard !UserDefaults.standard.bool(forKey: didMigrateKey) else {
            return .notNeeded
        }
        guard let realmURL = legacyRealmURL, FileManager.default.fileExists(atPath: realmURL.path) else {
            // 新規インストール。以後チェックしないようフラグだけ立てる
            UserDefaults.standard.set(true, forKey: didMigrateKey)
            return .notNeeded
        }

        do {
            let result = try migrate(realmURL: realmURL, context: context)
            try context.save()
            // 保存が成功した後にのみ退避する
            archiveRealmFiles(at: realmURL)
            UserDefaults.standard.set(true, forKey: didMigrateKey)
            return result
        } catch {
            // フラグを立てないので次回起動時に再挑戦できる
            return .failed(error.localizedDescription)
        }
    }

    // MARK: - 変換本体

    private static func migrate(realmURL: URL, context: ModelContext) throws -> RealmMigrationResult {
        // 旧バージョンは Realm 10.14.0 で書いており、現在の Realm 20 系とはファイル形式が違う。
        // 形式の更新は書き込みを伴うため、読み取り専用では開けずに失敗する。
        // かといって元ファイルを直接書き換えると、移行に失敗したとき復旧できない。
        // そこで作業用の複製を作り、そちらを読み書き可能で開いて形式を更新させる。
        let workingURL = try makeWorkingCopy(of: realmURL)
        defer { removeRealmFiles(at: workingURL) }

        var configuration = Realm.Configuration(fileURL: workingURL)
        configuration.objectTypes = [LegacyAssessor.self, LegacyTargetPerson.self, LegacyFIM.self]
        // 旧アプリはスキーマバージョンを明示していなかったため 0 で書かれている。
        // 1 に上げたうえで中身を触らない移行を渡し、定義のずれがあっても開けるようにする
        configuration.schemaVersion = 1
        configuration.migrationBlock = { _, _ in }

        let realm = try Realm(configuration: configuration)

        var assessorCount = 0
        var targetPersonCount = 0
        var fimRecordCount = 0

        // 既にSwiftData側に存在するIDは二重登録しない（移行が途中で中断した場合の保険）
        let existingIDs = try existingAssessorIDs(context: context)

        for legacyAssessor in realm.objects(LegacyAssessor.self) {
            guard !existingIDs.contains(legacyAssessor.uuidString) else { continue }

            let assessor = Assessor(
                uuidString: legacyAssessor.uuidString,
                name: legacyAssessor.name,
                createdAt: .now
            )
            context.insert(assessor)
            assessorCount += 1

            for legacyTargetPerson in legacyAssessor.targetPersons {
                let targetPerson = TargetPerson(
                    uuidString: legacyTargetPerson.uuidString,
                    name: legacyTargetPerson.name,
                    createdAt: .now
                )
                context.insert(targetPerson)
                targetPerson.assessor = assessor
                targetPersonCount += 1

                for legacyFIM in legacyTargetPerson.FIM {
                    let record = FIMRecord(
                        uuidString: legacyFIM.uuidString,
                        // 旧データは createdAt が nil の可能性があるため退避値を用意する
                        createdAt: legacyFIM.createdAt ?? .distantPast,
                        updatedAt: legacyFIM.updatedAt
                    )
                    for (index, item) in FIMItem.allCases.enumerated() {
                        record[item] = legacyFIM.scoresInAssessmentOrder[index]
                    }
                    context.insert(record)
                    record.targetPerson = targetPerson
                    fimRecordCount += 1
                }
            }
        }

        return .completed(
            assessors: assessorCount,
            targetPersons: targetPersonCount,
            fimRecords: fimRecordCount
        )
    }

    private static func existingAssessorIDs(context: ModelContext) throws -> Set<String> {
        let descriptor = FetchDescriptor<Assessor>()
        return Set(try context.fetch(descriptor).map(\.uuidString))
    }

    // MARK: - 作業用の複製

    /// 元のRealmファイルを一時ディレクトリへ複製して、その場所を返す
    private static func makeWorkingCopy(of realmURL: URL) throws -> URL {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("realm-migration", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let destination = directory.appendingPathComponent("source.realm")
        removeRealmFiles(at: destination)
        // 本体だけ複製すればよい。lock や management は開くときに作り直される
        try FileManager.default.copyItem(at: realmURL, to: destination)
        return destination
    }

    /// Realm本体と付随ファイルをまとめて削除する
    private static func removeRealmFiles(at url: URL) {
        let fileManager = FileManager.default
        for suffix in ["", ".lock", ".note", ".management"] {
            try? fileManager.removeItem(at: URL(fileURLWithPath: url.path + suffix))
        }
    }

    // MARK: - 退避

    /// 移行済みのRealm関連ファイルをリネームして退避する。削除はしない。
    private static func archiveRealmFiles(at realmURL: URL) {
        let fileManager = FileManager.default
        let suffixes = ["", ".lock", ".note", ".management"]

        for suffix in suffixes {
            let source = URL(fileURLWithPath: realmURL.path + suffix)
            guard fileManager.fileExists(atPath: source.path) else { continue }

            let destination = URL(fileURLWithPath: realmURL.path + ".migrated-backup" + suffix)
            // 退避先が残っている場合は先に片付ける
            try? fileManager.removeItem(at: destination)
            try? fileManager.moveItem(at: source, to: destination)
        }
    }
}
