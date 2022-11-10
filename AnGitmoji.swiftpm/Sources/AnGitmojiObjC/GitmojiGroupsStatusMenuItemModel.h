#import <Foundation/Foundation.h>
#import <TargetConditionals.h>

#if TARGET_OS_OSX || TARGET_OS_MACCATALYST
NS_ASSUME_NONNULL_BEGIN

static NSNotificationName const NSNotificationNameGitmojiGroupsStatusMenuItemModelDidChangeGitmojiGroups = @"NSNotificationNameGitmojiGroupsStatusMenuItemModelDidChangeGitmojiGroups";
static NSString * const GitmojiGroupsStatusMenuItemModelDidChangeGitmojiGroupsDifferenceItemKey = @"GitmojiGroupsStatusMenuItemModelDidChangeGitmojiGroupsDifferenceItemKey";

static NSNotificationName const NSNotificationNameGitmojiGroupsStatusMenuItemModelDidChangeGitmojiGroup = @"NSNotificationNameGitmojiGroupsStatusMenuItemModelDidChangeGitmojiGroup";
static NSString * const GitmojiGroupsStatusMenuItemModelDidChangeGitmojiGroupDifferenceMapItemKey = @"GitmojiGroupsStatusMenuItemModelDidChangeGitmojiGroupDifferenceMapItemKey";

@interface GitmojiGroupsStatusMenuItemModel : NSObject

@end

NS_ASSUME_NONNULL_END
#endif
