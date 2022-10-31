import SwiftUI
import AnGitmojiCore

struct GitmojiGroupDetailView: View {
    @Environment(\.selectedGitmojiGroup) private var selectedGitmojiGroup: GitmojiGroup?
    @StateObject private var viewModel: GitmojiGroupDetailViewModel = .init()
    @State private var updateTask: Task<Void, Never>?
    
    var body: some View {
        if let gitmojis: [Gitmoji] = viewModel.gitmojis {
            Table(gitmojis) {
                TableColumn("Emoji", value: \.emoji)
                TableColumn("Code", value: \.code)
                TableColumn("Description") { value in
                    Text(value.detail)
                        .lineLimit(nil)
                }
                TableColumn("Semver") { value in
                    Text(value.semver ?? "No Semver")
                }
            }
                .onChange(of: selectedGitmojiGroup) { newValue in
                    update(using: newValue)
                }
        } else {
            Text("No Selection")
                .onChange(of: selectedGitmojiGroup) { newValue in
                    update(using: newValue)
                }
        }
    }
    
    private func update(using selectedGitmojiGroup: GitmojiGroup?) {
        updateTask?.cancel()
        updateTask = .detached { [viewModel] in
            await viewModel.update(using: selectedGitmojiGroup)
        }
    }
}

struct GitmojiGroupDetailViewl_Previews: PreviewProvider {
    static var previews: some View {
        GitmojiGroupDetailView()
    }
}
