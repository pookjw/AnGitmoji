import Foundation

public final class DIService: NSObject {
    public static var gitmojiUseCase: GitmojiUseCase {
        GitmojiUseCaseImpl(gitmojiRepository: gitmojiRepository, gitmojiJSONRepository: gitmojiJSONRepository)
    }
    
    @objc(gitmojiUseCase) public static var gitmojiUseCaseObjCRepresentable: GitmojiUseCaseObjCRepresentable {
        GitmojiUseCaseImpl(gitmojiRepository: gitmojiRepository, gitmojiJSONRepository: gitmojiJSONRepository)
    }
    
    static var gitmojiJSONDataSource: GitmojiJSONDataSource {
        GitmojiJSONNetwork()
    }
    
    static var gitmojiRepository: GitmojiRepository {
        GitmojiRepositoryImpl.shared
    }
    
    static var gitmojiJSONRepository: GitmojiJSONRepository {
        GitmojiJSONRepositoryImpl(gitmojiDataSource: gitmojiJSONDataSource)
    }
}
