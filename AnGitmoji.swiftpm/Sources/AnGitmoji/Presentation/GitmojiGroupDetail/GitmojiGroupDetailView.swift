import SwiftUI
import AnGitmojiCore

struct GitmojiGroupDetailView: View {
    @Environment(\.selectedGitmojiGroup) private var selectedGitmojiGroup: GitmojiGroup?
    @StateObject private var viewModel: GitmojiGroupDetailViewModel = .init()
    @State private var tasks: Set<Task<Void, Never>> = .init()
    @State private var selectedGitmojis: Set<Gitmoji.ID> = .init()
    @State private var sortOrder: [KeyPathComparator<Gitmoji>] = []
    
    var body: some View {
        if let selectedGitmojiGroup: GitmojiGroup,
           let gitmojis: [Gitmoji] = viewModel.gitmojis {
            Table(selection: $viewModel.selectedGitmojis, sortOrder: $viewModel.sortOrder) { 
                TableColumn("Emoji", value: \.emoji)
                TableColumn("Code", value: \.code)
                TableColumn("Description", value: \.detail)
            } rows: { 
                ForEach(gitmojis) { gitmoji in
                    TableRow(gitmoji)
                        .contextMenu { 
                            Button("Copy") { 
                                viewModel.copy(from: gitmoji)
                            }
                        }
                }
                .contextMenu { 
                    
                }
            }
                .onChange(of: selectedGitmojiGroup) { newValue in
                    update(using: newValue)
                }
                .navigationTitle(selectedGitmojiGroup.name)
#if os(macOS) || targetEnvironment(macCatalyst)
                .navigationSubtitle("\(gitmojis.count) items")
#endif
        } else {
            Text("No Selection")
                .onChange(of: selectedGitmojiGroup) { newValue in
                    update(using: newValue)
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
