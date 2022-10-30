import SwiftUI

struct GitmojiGroupListView: View {
    @StateObject private var viewModel: GitmojiGroupListViewModel = .init()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear {
//                print(viewModel.gitmojiGroups)
            }
    }
}

struct GitmojiGroupListView_Previews: PreviewProvider {
    static var previews: some View {
        GitmojiGroupListView()
    }
}
