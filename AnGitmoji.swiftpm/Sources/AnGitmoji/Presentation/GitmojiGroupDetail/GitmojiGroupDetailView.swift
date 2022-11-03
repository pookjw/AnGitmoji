import SwiftUI
import AnGitmojiCore

struct GitmojiGroupDetailView: View {
    @FetchRequest(sortDescriptors: []) private var fetchedGitmojis: FetchedResults<Gitmoji>
    @Environment(\.selectedGitmojiGroup) private var selectedGitmojiGroup: GitmojiGroup?
    @StateObject private var viewModel: GitmojiGroupDetailViewModel = .init()
    @State private var tasks: Set<Task<Void, Never>> = .init()
    
    @State private var isPresentedEditAlert: Bool = false
    @State private var editingGitmoji: Gitmoji?
    @State private var editingGitmojiEmoji: String = ""
    @State private var editingGitmojiCode: String = ""
    @State private var editingGitmojiName: String = ""
    @State private var editingGitmojiDetail: String = ""
    
    var body: some View {
        Group {
            if let selectedGitmojiGroup: GitmojiGroup = viewModel.selectedGitmojiGroup {
                Table(selection: $viewModel.selectedGitmojis, sortOrder: $viewModel.keyPathComparators) {
                    TableColumn("Emoji", value: \Gitmoji.emoji)
                    TableColumn("Name", value: \Gitmoji.name)
                    TableColumn("Code", value: \Gitmoji.code)
                    TableColumn("Description", value: \Gitmoji.detail) { gitmoji in
                        Text(gitmoji.detail)
                            .lineLimit(nil)
                    }
                    TableColumn("Count", value: \Gitmoji.count, comparator: IntComparator()) { gitmoji in
                        Text("\(gitmoji.count)")
                    }
                } rows: {
                    ForEach(fetchedGitmojis) { gitmoji in
                        TableRow(gitmoji)
                            .contextMenu {
                                Button("Edit") {
                                    presentEditAlert(gitmoji: gitmoji)
                                }
                                
                                Button("Copy") {
                                    tasks.insert(.detached { [viewModel] in
                                        do {
                                            try await viewModel.copy(gitmoji: gitmoji)
                                        } catch {
                                            fatalError("\(error)")
                                        }
                                    })
                                }
                                
                                Button("Delete") {
                                    tasks.insert(.detached { [viewModel] in
                                        do {
                                            try await viewModel.remove(gitmoji: gitmoji)
                                        } catch {
                                            fatalError("\(error)")
                                        }
                                    })
                                }
                                
                                Divider()
                                
                                Button("Reset Count") {
                                    tasks.insert(.detached { [viewModel] in
                                        do {
                                            try await viewModel.resetCount(gitmoji: gitmoji)
                                        } catch {
                                            fatalError("\(error)")
                                        }
                                        
                                    })
                                }
                            }
                    }
                }
                    .navigationTitle(selectedGitmojiGroup.name)
#if os(macOS) || targetEnvironment(macCatalyst)
                    .navigationSubtitle("\(viewModel.gitmojis.count) items")
#endif
            } else {
                Text("No Selection")
            }
        }
        .onChange(of: selectedGitmojiGroup) { newValue in
            tasks.forEach { $0.cancel() }
            tasks.removeAll()
            viewModel.selectedGitmojiGroup = newValue
        }
        .onChange(of: viewModel.nsPredicate) { newValue in
            fetchedGitmojis.nsPredicate = newValue
        }
        .onChange(of: viewModel.sortDescriptors) { newValue in
            fetchedGitmojis.sortDescriptors = newValue
        }
        .alert("Edit Gitmoji", isPresented: $isPresentedEditAlert) {
            TextField("Enter emoji here...", text: $editingGitmojiEmoji)
            TextField("Enter code here...", text: $editingGitmojiCode)
            TextField("Enter name here...", text: $editingGitmojiName)
            TextField("Enter detail here...", text: $editingGitmojiDetail)
            
            Button("OK", role: .cancel) {
                tasks.insert(.detached { [viewModel, editingGitmoji, editingGitmojiEmoji, editingGitmojiCode, editingGitmojiName, editingGitmojiDetail] in
                    do {
                        guard let editingGitmoji: Gitmoji else {
                            fatalError()
                        }
                        
                        try await viewModel.edit(
                            gitmoji: editingGitmoji,
                            emoji: editingGitmojiEmoji,
                            code: editingGitmojiCode,
                            name: editingGitmojiName,
                            detail: editingGitmojiDetail
                        )
                    } catch {
                        fatalError("\(error)")
                    }
                })
                
                clearEditAlertGitmoji()
            }
            
            Button("Cancel", role: .destructive) {
                clearEditAlertGitmoji()
            }
        } message: {
            Text(String(describing: editingGitmoji?.objectID))
        }
    }
    
    private func presentEditAlert(gitmoji: Gitmoji) {
        editingGitmoji = gitmoji
        editingGitmojiEmoji = gitmoji.emoji
        editingGitmojiCode = gitmoji.code
        editingGitmojiName = gitmoji.name
        editingGitmojiDetail = gitmoji.detail
        isPresentedEditAlert = true
    }
    
    private func clearEditAlertGitmoji() {
        editingGitmoji = nil
        editingGitmojiEmoji = ""
        editingGitmojiCode = ""
        editingGitmojiName = ""
        editingGitmojiDetail = ""
    }
}

struct GitmojiGroupDetailViewl_Previews: PreviewProvider {
    static var previews: some View {
        GitmojiGroupDetailView()
    }
}
