//
//  AssessorListView.swift
//  FunctionalIndependenceMeasure
//
//  評価者一覧。アプリのルート画面。
//

import SwiftUI
import SwiftData

struct AssessorListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Assessor.createdAt) private var assessors: [Assessor]

    @State private var path = NavigationPath()
    @State private var isAddingAssessor = false
    @State private var editingAssessor: Assessor?
    @State private var deletionTarget: Assessor?

    var body: some View {
        NavigationStack(path: $path) {
            Group {
                if assessors.isEmpty {
                    ContentUnavailableView {
                        Label("評価者が登録されていません", systemImage: "person.crop.circle.badge.plus")
                    } description: {
                        Text("右上の＋から評価者を登録してください。")
                    }
                } else {
                    assessorList
                }
            }
            .navigationTitle("評価者")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isAddingAssessor = true
                    } label: {
                        Label("評価者を追加", systemImage: "plus")
                    }
                }
            }
            .navigationDestination(for: Assessor.self) { assessor in
                TargetPersonListView(assessor: assessor)
            }
            .navigationDestination(for: TargetPerson.self) { targetPerson in
                FunctionSelectionView(targetPerson: targetPerson)
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case let .newAssessment(targetPerson):
                    AssessmentView(targetPerson: targetPerson)
                case let .fimRecords(targetPerson):
                    FIMRecordListView(targetPerson: targetPerson)
                case let .fimDetail(record):
                    DetailFIMView(record: record)
                }
            }
        }
        .sheet(isPresented: $isAddingAssessor) {
            NameInputSheet(title: "評価者の登録", placeholder: "評価者名") { name in
                modelContext.insert(Assessor(name: name))
            }
        }
        .sheet(item: $editingAssessor) { assessor in
            NameInputSheet(title: "評価者の編集", placeholder: "評価者名", initialName: assessor.name) { name in
                assessor.name = name
            }
        }
        .confirmationDialog(
            "この評価者を削除しますか？",
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
            Text("登録されている対象者と評価結果もあわせて削除されます。")
        }
    }

    private var assessorList: some View {
        List {
            ForEach(assessors) { assessor in
                NavigationLink(value: assessor) {
                    Text(assessor.name)
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        deletionTarget = assessor
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                    Button {
                        editingAssessor = assessor
                    } label: {
                        Label("編集", systemImage: "pencil")
                    }
                    .tint(Theme.main)
                }
            }
        }
    }
}
