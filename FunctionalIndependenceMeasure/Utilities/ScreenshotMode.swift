//
//  ScreenshotMode.swift
//  FunctionalIndependenceMeasure
//
//  ストア用スクリーンショットの撮影モード（Debug ビルドのみ）。
//  起動引数 `-ssScene 1〜6` で、見本データ（架空の評価者・対象者・点数）を
//  メモリ上のデータベースに入れ、指定の画面を開いた状態で起動する。
//  端末に保存済みの評価データには一切触れない。
//

#if DEBUG
import SwiftUI
import SwiftData

enum ScreenshotMode {
    /// 撮影する場面（1〜6）。起動引数が無ければ nil
    static let scene: Int? = {
        let args = ProcessInfo.processInfo.arguments
        guard let i = args.firstIndex(of: "-ssScene"), args.indices.contains(i + 1) else { return nil }
        return Int(args[i + 1])
    }()

    static var isActive: Bool { scene != nil }

    /// 場面1：評価画面をどの項目から始めるか（ベッド・椅子・車椅子移乗）と、選択済みの点数
    static var assessmentStartIndex: Int? { scene == 1 ? FIMItem.transfersBedChairWheelchair.rawValue : nil }
    static let assessmentSelectedScore = 5

    /// 場面4：PDF のプレビューを開いておく
    static var showsPDF: Bool { scene == 4 }

    /// 場面5：評価の編集画面を開いておく
    static var showsEdit: Bool { scene == 5 }

    /// 見本の点数（評価順18項目：運動13・認知5）
    static let sampleScores = [6, 5, 4, 5, 4, 5, 6, 6, 5, 5, 4, 5, 3, 6, 6, 5, 5, 5]

    static func makeContainer() -> ModelContainer? {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try? ModelContainer(for: Assessor.self, TargetPerson.self, FIMRecord.self, configurations: config)
    }

    @MainActor private static var seededPath: NavigationPath?

    /// 見本データを入れ、場面に応じた画面遷移の経路を返す（画面の再描画で二重に入れない）
    @MainActor
    static func seed(_ context: ModelContext) -> NavigationPath {
        if let seededPath { return seededPath }
        let path = makeSeed(context)
        seededPath = path
        return path
    }

    @MainActor
    private static func makeSeed(_ context: ModelContext) -> NavigationPath {
        let calendar = Calendar(identifier: .gregorian)
        func date(_ m: Int, _ d: Int, _ h: Int, _ min: Int) -> Date {
            calendar.date(from: DateComponents(year: 2026, month: m, day: d, hour: h, minute: min)) ?? .now
        }

        let assessors = ["高橋 健太（PT）", "佐藤 美咲（OT）", "中村 由紀（看護師）"]
            .enumerated()
            .map { Assessor(name: $1, createdAt: date(1, 5, 9, $0)) }
        assessors.forEach(context.insert)
        let assessor = assessors[0]

        let names = ["田中 正雄", "山本 花子", "小林 清", "加藤 和子", "吉田 武", "松本 千代"]
        let persons = names.enumerated().map { TargetPerson(name: $1, createdAt: date(2, 1, 9, $0)) }
        for person in persons {
            context.insert(person)
            person.assessor = assessor
        }
        let person = persons[0]

        // 架空の点数。改善・悪化を示唆しないよう、小さく上下させるだけにする
        let history: [(Date, [Int])] = [
            (date(6, 3, 10, 30), [6, 5, 4, 5, 4, 5, 6, 6, 5, 5, 4, 5, 3, 6, 6, 5, 5, 4]),
            (date(7, 1, 14, 0), [6, 5, 4, 5, 4, 5, 6, 6, 5, 5, 4, 5, 3, 6, 6, 5, 5, 5]),
            (date(8, 5, 10, 15), [6, 5, 4, 5, 4, 5, 6, 5, 5, 5, 4, 5, 3, 6, 6, 5, 5, 5]),
            (date(9, 2, 11, 0), [6, 5, 4, 5, 4, 5, 6, 6, 5, 5, 4, 5, 3, 6, 6, 5, 4, 5]),
            (date(10, 7, 15, 30), sampleScores)
        ]
        var latest: FIMRecord?
        for (createdAt, scores) in history {
            let record = FIMRecord(scores: scores, createdAt: createdAt)
            context.insert(record)
            record.targetPerson = person
            latest = record
        }
        try? context.save()

        var path = NavigationPath()
        switch scene {
        case 1:
            path.append(assessor)
            path.append(person)
            path.append(Route.newAssessment(person))
        case 2, 4, 5:
            path.append(assessor)
            path.append(person)
            path.append(Route.fimRecords(person))
            if let latest { path.append(Route.fimDetail(latest)) }
        case 3:
            path.append(assessor)
            path.append(person)
            path.append(Route.fimRecords(person))
        case 6:
            path.append(assessor)
        default:
            break
        }
        return path
    }
}

#if targetEnvironment(macCatalyst)
// MARK: - Mac（Catalyst）の撮影
/// `-ssSnap` を付けると、ウィンドウを 1280×800 に固定し、数秒後に画面を PNG にして標準出力へ
/// （`SNAP <名前> <base64>` の 1 行ずつ）書き出して終了する。
/// サンドボックスの外へファイルを書けず、画面がロック中でも撮れるよう、レイヤーを直接描いて標準出力で渡す。
extension ScreenshotMode {
    static var wantsSnapshot: Bool { ProcessInfo.processInfo.arguments.contains("-ssSnap") }

    @MainActor
    static func snapshotIfRequested() async {
        guard wantsSnapshot, let scene else { return }
        let size = CGSize(width: 1280, height: 800)
        for case let windowScene as UIWindowScene in UIApplication.shared.connectedScenes {
            windowScene.sizeRestrictions?.minimumSize = size
            windowScene.sizeRestrictions?.maximumSize = size
            // iPhone 版のストア画像とそろえてライトで撮る
            windowScene.windows.forEach { $0.overrideUserInterfaceStyle = .light }
        }
        try? await Task.sleep(for: .seconds(scene == 4 || scene == 5 ? 5 : 3))
        let windows = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .filter { !$0.isHidden && $0.bounds.width > 100 }
        for (index, window) in windows.enumerated() {
            let format = UIGraphicsImageRendererFormat()
            format.scale = 2
            let image = UIGraphicsImageRenderer(bounds: window.bounds, format: format).image { context in
                window.layer.render(in: context.cgContext)
            }
            if let data = image.pngData() {
                emit(name: index == 0 ? "scene\(scene).png" : "scene\(scene)-w\(index).png", data: data)
            }
            // シート（編集画面など）は Mac では別の面に出るため、表示中の画面も個別に描く
            var presented = window.rootViewController?.presentedViewController
            var depth = 0
            while let controller = presented, let view = controller.view, view.bounds.width > 100 {
                depth += 1
                let sheet = UIGraphicsImageRenderer(bounds: view.bounds, format: format).image { context in
                    view.layer.render(in: context.cgContext)
                }
                if let data = sheet.pngData() { emit(name: "scene\(scene)-sheet\(depth).png", data: data) }
                presented = controller.presentedViewController
            }
        }
        // 書き出した PDF も渡す（Mac で PDF が正しく作れるかを確かめるため）
        let temp = FileManager.default.temporaryDirectory
        for file in (try? FileManager.default.contentsOfDirectory(at: temp, includingPropertiesForKeys: nil)) ?? []
        where file.pathExtension == "pdf" {
            if let data = try? Data(contentsOf: file) { emit(name: "scene\(scene).pdf", data: data) }
        }
        exit(0)
    }

    private static func emit(name: String, data: Data) {
        print("SNAP \(name) \(data.base64EncodedString())")
        fflush(stdout)
    }
}
#endif
#endif
