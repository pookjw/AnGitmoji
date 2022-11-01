import SwiftUI
import AnGitmojiCore

struct GitmojiGroupDetailView: View {
    @Environment(\.selectedGitmojiGroup) private var selectedGitmojiGroup: GitmojiGroup?
    @StateObject private var viewModel: GitmojiGroupDetailViewModel = .init()
    @State private var tasks: Set<Task<Void, Never>> = .init()
    
    var body: some View {
        Group {
            if let selectedGitmojiGroup: GitmojiGroup {
                Table(selection: $viewModel.selectedGitmojis, sortOrder: $viewModel.sortOrders) {
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
                    ForEach(viewModel.gitmojis) { gitmoji in
                        TableRow(gitmoji)
                            .contextMenu {
                                Button("Copy") {
                                    tasks.insert(.detached { [viewModel] in
                                        do {
                                            try await viewModel.copy(from: gitmoji)
                                        } catch {
                                            fatalError("\(error)")
                                        }
                                    })
                                }
                                
                                Button("Reset Count") {
                                    fatalError("TODO")
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
            update(using: newValue)
        }
        .toolbar {
            Button("Test") {
                
            }
        }
    }
    
    private func update(using selectedGitmojiGroup: GitmojiGroup?) {
        tasks = .init()
        tasks.insert(.detached { [viewModel] in
            await viewModel.update(using: selectedGitmojiGroup)
        })
    }
}

struct GitmojiGroupDetailViewl_Previews: PreviewProvider {
    static var previews: some View {
        GitmojiGroupDetailView()
    }
}
