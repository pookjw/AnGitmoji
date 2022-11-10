#import "GitmojiGroupsStatusMenuItem.h"
#import "GitmojiGroupsStatusMenuItemModel.h"
@import AnGitmojiCore;

#if TARGET_OS_OSX || TARGET_OS_MACCATALYST

@interface GitmojiGroupsStatusMenuItem ()
@property (strong) id mainMenu; // NSMenu
@property (strong) NSMapTable<GitmojiGroup *, id> *gitmojiGroupMenuItems; // NSMenuItem
@property (strong) NSMapTable<GitmojiGroup *, id> *gitmojiGroupMenu; // NSMenu
@property (strong) NSMapTable<Gitmoji *, id> *gitmojiMenuItems; // NSMenuItem
@property (strong) GitmojiGroupsStatusMenuItemModel *model;
@end

@implementation GitmojiGroupsStatusMenuItem

- (instancetype)init {
    if (self = [super init]) {
        [self setAttributes];
        [self configureMainMenu];
        [self configureModel];
    }
    
    return self;
}

- (void)setAttributes {
    [self setSystemSymbolName:@"face.smiling" accessibilityDescription:nil];
}

- (void)configureMainMenu {
    id mainMenu = ((id (*)(Class, SEL))objc_msgSend)(NSClassFromString(@"NSMenu"), @selector(new));
    self.mainMenu = mainMenu;
}

- (void)configureModel {
    GitmojiGroupsStatusMenuItemModel *model = [GitmojiGroupsStatusMenuItemModel new];
    self.model = model;
}

@end

#endif
