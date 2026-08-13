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
    static let developerSiteURL = URL(string: "https://sites.google.com/view/muranakar")!

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

    /// 回数を1つ進め、レビュー依頼すべきタイミングなら true を返す
    static func incrementAndShouldRequestReview() -> Bool {
        let count = UserDefaults.standard.integer(forKey: key) + 1
        UserDefaults.standard.set(count, forKey: key)
        return AppLinks.reviewRequestCounts.contains(count)
    }
}
