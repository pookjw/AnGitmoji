import Foundation

public final class DIService: NSObject {
    static var gitmojiUseCase: GitmojiUseCase {
        let gitmojiJSONDataSource: GitmojiJSONDataSource = GitmojiJSONNetwork()
        
        let gitmojiRepository: GitmojiRepository = GitmojiRepositoryImpl.shared
        let gitmojiJSONRepository: GitmojiJSONRepository = GitmojiJSONRepositoryImpl(gitmojiDataSource: gitmojiJSONDataSource)
        
        let gitmojiUseCase: GitmojiUseCase = GitmojiUseCaseImpl(gitmojiRepository: gitmojiRepository, gitmojiJSONRepository: gitmojiJSONRepository)
        
        return gitmojiUseCase
    }
    
    @objc(gitmojiUseCase) static var gitmojiUseCaseObjCRepresentable: GitmojiUseCaseObjCRepresentable {
        let gitmojiJSONDataSource: GitmojiJSONDataSource = GitmojiJSONNetwork()
        
        let gitmojiRepository: GitmojiRepository = GitmojiRepositoryImpl.shared
        let gitmojiJSONRepository: GitmojiJSONRepository = GitmojiJSONRepositoryImpl(gitmojiDataSource: gitmojiJSONDataSource)
        
        let gitmojiUseCaseObjCRepresentable: GitmojiUseCaseObjCRepresentable = GitmojiUseCaseImpl(gitmojiRepository: gitmojiRepository, gitmojiJSONRepository: gitmojiJSONRepository)
        
        return gitmojiUseCaseObjCRepresentable
    }
}
