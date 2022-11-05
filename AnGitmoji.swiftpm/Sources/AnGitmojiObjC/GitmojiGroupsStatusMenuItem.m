#import "GitmojiGroupsStatusMenuItem.h"
@import AnGitmojiCore;

#if TARGET_OS_OSX || TARGET_OS_MACCATALYST

@interface GitmojiGroupsStatusMenuItem ()
@property (strong) id<GitmojiUseCase> gitmojiUseCase;
@end

@implementation GitmojiGroupsStatusMenuItem

- (instancetype)init {
    if (self = [super init]) {
        [self setAttributes];
        [self configureGitmojiUseCase];
    }
    
    return self;
}

- (void)setAttributes {
    [self setSystemSymbolName:@"face.smiling" accessibilityDescription:nil];
}

- (void)configureGitmojiUseCase {
    id<GitmojiUseCase> gitmojiUseCase = DIService.gitmojiUseCase;
    self.gitmojiUseCase = gitmojiUseCase;
}

@end

#endif
