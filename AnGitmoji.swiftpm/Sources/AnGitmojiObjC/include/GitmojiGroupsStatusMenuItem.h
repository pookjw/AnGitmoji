#import "CatalystStatusMenuItem.h"
#import <TargetConditionals.h>

#if TARGET_OS_OSX || TARGET_OS_MACCATALYST
NS_ASSUME_NONNULL_BEGIN

@interface GitmojiGroupsStatusMenuItem : CatalystStatusMenuItem
- (instancetype)initWithLength:(CGFloat)length NS_UNAVAILABLE;
- (void)setSystemSymbolName:(NSString *)name accessibilityDescription:(NSString * _Nullable)description NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
#endif
