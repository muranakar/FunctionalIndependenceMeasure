//
//  TargetPersonListView.swift
//  FunctionalIndependenceMeasure
//
//  ある評価者に紐づく対象者の一覧。
//

import SwiftUI
import SwiftData

struct TargetPersonListView: View {
    let assessor: Assessor

    @Environment(\.modelContext) private var modelContext
    @State private var isAddingTargetPerson = false
    @State private var editingTargetPerson: TargetPerson?
    @State private var deletionTarget: TargetPerson?

    private var targetPersons: [TargetPerson] {
        assessor.targetPersons.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        Group {
            if targetPersons.isEmpty {
                ContentUnavailableView {
                    Label("対象者が登録されていません", systemImage: "person.2.badge.plus")
                } description: {
                    Text("右上の＋から対象者を登録してください。")
                }
            } else {
                targetPersonList
            }
        }
        .navigationTitle("評価者:　\(assessor.name)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    isAddingTargetPerson = true
                } label: {
                    Label("対象者を追加", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $isAddingTargetPerson) {
            NameInputSheet(title: "対象者の登録", placeholder: "対象者名") { name in
                let targetPerson = TargetPerson(name: name)
                modelContext.insert(targetPerson)
                targetPerson.assessor = assessor
            }
        }
        .sheet(item: $editingTargetPerson) { targetPerson in
            NameInputSheet(title: "対象者の編集", placeholder: "対象者名", initialName: targetPerson.name) { name in
                targetPerson.name = name
            }
        }
        .confirmationDialog(
            "この対象者を削除しますか？",
            isPresented: .init(get: { deletionTarget != nil }, set: { if !$0 { deletionTarget = nil } }),
            titleVisibility: .visible
        ) {
            Button("削除", role: .destructive) {
                if let deletionTarget {
                    modelContext.delete(deletionTarget)
                }
                deletionTarget = nil
            }
            Button("キャンセル", role: .cancel) { deletionTarget = nil }
        } message: {
            Text("この対象者の評価結果もあわせて削除されます。")
        }
    }

    private var targetPersonList: some View {
        List {
            ForEach(targetPersons) { targetPerson in
                NavigationLink(value: targetPerson) {
                    Text(targetPerson.name)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        deletionTarget = targetPerson
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                    Button {
                        editingTargetPerson = targetPerson
                    } label: {
                        Label("編集", systemImage: "pencil")
                    }
                    .tint(Theme.main)
                }
            }
        }
    }
}
