#import "GitmojiGroupsStatusMenuItem.h"
#import <objc/message.h>
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
    [self setSystemSymbolName:@"pencil.circle" accessibilityDescription:nil];
}

- (void)configureGitmojiUseCase {
    // No header declaration of `+[DIService gitmojiUseCase]`. Seems like SPM bug.
    id<GitmojiUseCase> gitmojiUseCase = ((id<GitmojiUseCase> (*)(Class, SEL))objc_msgSend)(DIService.class, @selector(gitmojiUseCase));
    self.gitmojiUseCase = gitmojiUseCase;
}

@end

#endif
