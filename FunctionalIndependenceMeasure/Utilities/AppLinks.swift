//
//  AppLinks.swift
//  FunctionalIndependenceMeasure
//
//  SNS共有・レビュー導線。リンクと文面は旧バージョンから引き継いでいる。
//

import Foundation

enum AppLinks {
    static let appStoreURL = URL(string: "https://apps.apple.com/jp/app/fim/id1606480076")!
    static let reviewURL = URL(string: "https://apps.apple.com/app/id1606480076?action=write-review")!
    static let developerSiteURL = URL(string: "https://irodori-labo.com/")!

    // swiftlint:disable:next line_length
    private static let shareMessage = "ADL評価のFIMを評価することが可能！\n #ADL #FIM #身体機能 #病院 #クリニック #在宅 #リハビリ #理学療法士 #作業療法士 #介護 #評価 #身体評価   \n\(appStoreURL.absoluteString)"

    /// X（旧Twitter）の投稿画面
    static var xShareURL: URL? {
        guard let encoded = shareMessage.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: "https://twitter.com/intent/tweet?text=\(encoded)")
    }

    /// LINEの共有画面
    static var lineShareURL: URL? {
        guard let encoded = ("https://line.me/R/share?text=" + "/" + shareMessage)
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: encoded)
    }

    /// レビュー依頼の閾値。評価完了がこの回数に達したときだけ依頼する
    static let reviewRequestCounts: Set<Int> = [10, 31, 50]
}

// MARK: - ReviewCounter
/// 評価完了回数を数えてレビュー依頼のタイミングを判断する
enum ReviewCounter {
    // 旧バージョンから引き継いでいるキー。変更すると既存ユーザーの回数が0に戻り、
    // レビュー依頼が再び出てしまうため変えないこと
    private static let key = "review20220726"
    private static let lastAskKey = "review.lastAskAt"
    private static let lastVersionKey = "review.lastAskVersion"
    static let minDaysBetween: Double = 120

    /// 評価を終えて結果を閉じたとき true にし、戻った先の画面（FunctionSelectionView）で出す
    private static var pendingRequest = false

    /// UIテスト実行時はレビュー依頼のダイアログが操作を妨げるため出さない
    private static var isDisabled: Bool {
        ProcessInfo.processInfo.arguments.contains("-disableReviewRequest")
    }

    private static var currentVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }

    /// 完了回数が節目（10・31・50 回目）・前回の依頼から 120 日以上・版ごと 1 回まで
    static func shouldRequest(count: Int, lastAsk: Date?, lastVersion: String?, currentVersion: String, now: Date) -> Bool {
        guard AppLinks.reviewRequestCounts.contains(count) else { return false }
        if lastVersion == currentVersion { return false }
        if let lastAsk, now.timeIntervalSince(lastAsk) < minDaysBetween * 86_400 { return false }
        return true
    }

    /// 回数を1つ進め、レビュー依頼すべきタイミングなら true を返す（評価を中止したときは呼ばない）
    static func incrementAndShouldRequestReview(defaults: UserDefaults = .standard, now: Date = Date()) -> Bool {
        let count = defaults.integer(forKey: key) + 1
        defaults.set(count, forKey: key)
        guard !isDisabled else { return false }
        let version = currentVersion
        guard shouldRequest(count: count,
                            lastAsk: defaults.object(forKey: lastAskKey) as? Date,
                            lastVersion: defaults.string(forKey: lastVersionKey),
                            currentVersion: version, now: now) else { return false }
        defaults.set(now, forKey: lastAskKey)
        defaults.set(version, forKey: lastVersionKey)
        return true
    }

    /// 評価完了で依頼すると決まったときに呼ぶ。戻った先の画面で出す
    static func schedulePendingRequest() { pendingRequest = true }

    /// 戻った先の画面で呼ぶ。出すべきなら true を返し、印を消す
    static func consumePendingRequest() -> Bool {
        defer { pendingRequest = false }
        return pendingRequest
    }
}
