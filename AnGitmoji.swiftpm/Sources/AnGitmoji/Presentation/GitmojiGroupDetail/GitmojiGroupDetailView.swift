import SwiftUI
import AnGitmojiCore

struct GitmojiGroupDetailView: View {
    @FetchRequest(sortDescriptors: []) private var fetchedGitmojis: FetchedResults<Gitmoji>
    @Environment(\.selectedGitmojiGroup) private var selectedGitmojiGroup: GitmojiGroup?
    @StateObject private var viewModel: GitmojiGroupDetailViewModel = .init()
    @State private var tasks: Set<Task<Void, Never>> = .init()
    @State private var predicate: NSPredicate = .init()
    var body: some View {
        Group {
            if let selectedGitmojiGroup: GitmojiGroup {
                Table(selection: $viewModel.selectedGitmojis, sortOrder: $viewModel.keyPathComparators) {
                    TableColumn("Emoji", value: \.emoji)
                    TableColumn("Code", value: \.code)
                    TableColumn("Description", value: \.detail) { gitmoji in
                        Text(gitmoji.detail)
                            .lineLimit(nil)
                    }
                    TableColumn("Count", value: \.count, comparator: IntComparator()) { gitmoji in
                        Text("\(gitmoji.count)")
                    }
                } rows: {
                    ForEach(fetchedGitmojis) { gitmoji in
                        TableRow(gitmoji)
                            .contextMenu {
                                Button("Edit") {
                                    fatalError("TODO")
                                }
                                
                                Button("Copy") {
                                    tasks.insert(.detached { [viewModel] in
                                        do {
                                            try await viewModel.copy(from: gitmoji)
                                        } catch {
                                            fatalError("\(error)")
                                        }
                                    })
                                }
                                
                                Divider()
                                
                                Button("Reset Count") {
                                    tasks.insert(.detached { [viewModel] in
                                        do {
                                            try await viewModel.resetCount(of: gitmoji)
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
        .toolbar {
            Button("Test") {
                
            }
        }
    }
}

struct GitmojiGroupDetailViewl_Previews: PreviewProvider {
    static var previews: some View {
        GitmojiGroupDetailView()
    }
}
