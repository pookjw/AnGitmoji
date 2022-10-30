#import <UIKit/UIKit.h>
#import <TargetConditionals.h>

#if TARGET_OS_OSX || TARGET_OS_MACCATALYST
NS_ASSUME_NONNULL_BEGIN

static const CGFloat CatalystStatusMenuItemVariableLength = -1.0;
static const CGFloat CatalystStatusMenuItemLength = -2.0;

@interface CatalystStatusMenuItem : NSObject
@property (strong) id nsStatusItem;
- (instancetype)initWithLength:(CGFloat)length NS_DESIGNATED_INITIALIZER;
- (void)setSystemSymbolName:(NSString *)name accessibilityDescription:(NSString * _Nullable)description;
@end

NS_ASSUME_NONNULL_END
#endif
