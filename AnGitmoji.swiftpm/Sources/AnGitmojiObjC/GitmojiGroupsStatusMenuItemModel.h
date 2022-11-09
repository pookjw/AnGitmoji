#import <Foundation/Foundation.h>
#import <TargetConditionals.h>

#if TARGET_OS_OSX || TARGET_OS_MACCATALYST
NS_ASSUME_NONNULL_BEGIN

static NSNotificationName const NSNotificationNameGitmojiGroupsStatusMenuItemModelDidChangeSnapshot = @"GitmojiGroupsStatusMenuItemModelDidChangeSnapshot";
static NSString * const GitmojiGroupsStatusMenuItemModelDidChangeSnapshotItemKey = @"GitmojiGroupsStatusMenuItemModelDidChangeSnapshotItemKey";

@interface GitmojiGroupsStatusMenuItemModel : NSObject

@end

NS_ASSUME_NONNULL_END
#endif
