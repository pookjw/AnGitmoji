import SwiftUI
import AnGitmojiCore

struct GitmojiGroupDetailView: View {
    @FetchRequest(
        sortDescriptors: [],
        // When change of selectedGitmojiGroup is detected, there's no predicate in short time.
        // During that time, this view will show all Gitmoji objects without filtering. Below code will prevent it.
        predicate: NSPredicate(value: false),
        animation: .default
    ) private var fetchedGitmojis: FetchedResults<Gitmoji>
    @Environment(\.selectedGitmojiGroup) private var selectedGitmojiGroup: GitmojiGroup?
    @StateObject private var viewModel: GitmojiGroupDetailViewModel = .init()
    @State private var tasks: Set<Task<Void, Never>> = .init()
    
    var body: some View {
        Group {
            if viewModel.selectedGitmojiGroup != nil {
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
                                        await viewModel.prepareEditAlert(gitmoji: gitmoji)
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
                .navigationTitle("\(selectedGitmojiGroup?.name ?? "")")
#if os(macOS) || targetEnvironment(macCatalyst)
                .navigationSubtitle("\(viewModel.gitmojis.count) gitmojis")
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
        .onReceive(viewModel.nsPredicate.publisher) { newValue in
            fetchedGitmojis.nsPredicate = newValue
        }
        .onReceive(viewModel.sortDescriptors.publisher) { newValue in
//            fetchedGitmojis.sortDescriptors = newValue
            viewModel.sortDescriptors.pu
        }
        .searchable(text: $viewModel.searchingText)
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
            
            Button("Cancel", role: .destructive) {
                tasks.insert(.detached { [viewModel] in
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
