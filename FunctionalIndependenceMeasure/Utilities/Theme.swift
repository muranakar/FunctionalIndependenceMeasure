//
//  Theme.swift
//  FunctionalIndependenceMeasure
//
//  旧 Colors.swift の配色をSwiftUIへ引き継いだもの。
//

import SwiftUI

enum Theme {
    static let base = Color(hex: "F6F5F5")
    static let main = Color(hex: "459acc")
    static let complementary = Color(hex: "d89987")
    static let lightBlue = Color(hex: "56C1FF")
    static let darkBlue = Color(hex: "0076BA")
}

extension Color {
    init(hex: String, alpha: Double = 1.0) {
        let conversion = Int(hex, radix: 16) ?? 0
        let red = Double((conversion >> 16) & 0xFF) / 255
        let green = Double((conversion >> 8) & 0xFF) / 255
        let blue = Double(conversion & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: min(max(alpha, 0), 1))
    }
}

extension DateFormatter {
    /// 評価日時の表示用フォーマッタ
    static let evaluated: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy'年'MM'月'dd'日' HH'時'mm'分'"
        return formatter
    }()

    /// PDFのファイル名・作成日に使うフォーマッタ
    static let pdfDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
