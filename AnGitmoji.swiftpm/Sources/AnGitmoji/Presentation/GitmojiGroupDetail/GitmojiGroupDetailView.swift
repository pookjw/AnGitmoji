import SwiftUI
import AnGitmojiCore

struct GitmojiGroupDetailView: View {
    @FetchRequest(sortDescriptors: []) private var fetchedGitmojis: FetchedResults<Gitmoji>
    @Environment(\.selectedGitmojiGroup) private var selectedGitmojiGroup: GitmojiGroup?
    @StateObject private var viewModel: GitmojiGroupDetailViewModel = .init()
    @State private var tasks: Set<Task<Void, Never>> = .init()
    
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
                                    tasks.insert(.detached { [viewModel] in
                                        do {
                                            try await viewModel.prepareEditAlert(gitmoji: gitmoji)
                                        } catch {
                                            fatalError("\(error)")
                                        }
                                    })
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
        .alert("Edit Gitmoji", isPresented: $viewModel.isPresentedEditAlert) {
            TextField("Enter emoji here...", text: $viewModel.editingGitmojiEmoji)
            TextField("Enter code here...", text: $viewModel.editingGitmojiCode)
            TextField("Enter name here...", text: $viewModel.editingGitmojiName)
            TextField("Enter detail here...", text: $viewModel.editingGitmojiDetail)
            
            Button("OK", role: .cancel) {
                tasks.insert(.detached { [viewModel] in
                    do {
                        try await viewModel.endEditAlert(finished: true)
                    } catch {
                        fatalError("\(error)")
                    }
                })
            }
            
            Button("Cancel", role: .destructive) {tasks.insert(.detached { [viewModel] in
                do {
                    try await viewModel.endEditAlert(finished: false)
                } catch {
                    fatalError("\(error)")
                }
            })
            }
        }
    }
}

struct GitmojiGroupDetailViewl_Previews: PreviewProvider {
    static var previews: some View {
        GitmojiGroupDetailView()
    }
}
