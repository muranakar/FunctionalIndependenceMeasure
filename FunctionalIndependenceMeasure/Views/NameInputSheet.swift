//
//  NameInputSheet.swift
//  FunctionalIndependenceMeasure
//
//  評価者・対象者の名前入力に共通で使うシート。
//

import SwiftUI

struct NameInputSheet: View {
    let title: String
    let placeholder: String
    @State private var name: String
    let onSave: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool

    init(title: String, placeholder: String, initialName: String = "", onSave: @escaping (String) -> Void) {
        self.title = title
        self.placeholder = placeholder
        self._name = State(initialValue: initialName)
        self.onSave = onSave
    }

    private var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField(placeholder, text: $name)
                    .focused($isFocused)
                    .submitLabel(.done)
                    .onSubmit(save)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存", action: save)
                        .disabled(trimmedName.isEmpty)
                }
            }
            .onAppear { isFocused = true }
        }
        .presentationDetents([.medium])
    }

    private func save() {
        guard !trimmedName.isEmpty else { return }
        onSave(trimmedName)
        dismiss()
    }
}
