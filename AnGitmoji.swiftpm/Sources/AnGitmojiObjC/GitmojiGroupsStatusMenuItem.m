#import "GitmojiGroupsStatusMenuItem.h"
#import "GitmojiGroupsStatusMenuItemModel.h"
@import AnGitmojiCore;

#if TARGET_OS_OSX || TARGET_OS_MACCATALYST

@interface GitmojiGroupsStatusMenuItem ()
@property (strong) GitmojiGroupsStatusMenuItemModel *model;
@end

@implementation GitmojiGroupsStatusMenuItem

- (instancetype)init {
    if (self = [super init]) {
        [self setAttributes];
        [self configureModel];
    }
    
    return self;
}

- (void)setAttributes {
    [self setSystemSymbolName:@"face.smiling" accessibilityDescription:nil];
}

- (void)configureModel {
    GitmojiGroupsStatusMenuItemModel *model = [GitmojiGroupsStatusMenuItemModel new];
    self.model = model;
}

@end

#endif
