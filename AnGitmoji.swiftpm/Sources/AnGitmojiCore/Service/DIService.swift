public struct DIService {
    static var gitmojiUseCase: GitmojiUseCase {
        let gitmojiJSONDataSource: GitmojiJSONDataSource = GitmojiJSONNetwork()
        
        let gitmojiRepository: GitmojiRepository = GitmojiRepositoryImpl.shared
        let gitmojiJSONRepository: GitmojiJSONRepository = GitmojiJSONRepositoryImpl(gitmojiDataSource: gitmojiJSONDataSource)
        
        let gitmojiUseCase: GitmojiUseCase = GitmojiUseCaseImpl(gitmojiRepository: gitmojiRepository, gitmojiJSONRepository: gitmojiJSONRepository)
        
        return gitmojiUseCase
    }
}
