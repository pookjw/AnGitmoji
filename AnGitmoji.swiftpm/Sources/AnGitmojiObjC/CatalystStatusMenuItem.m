#import "CatalystStatusMenuItem.h"
#import <objc/message.h>
#import <objc/runtime.h>

#if TARGET_OS_OSX || TARGET_OS_MACCATALYST

@interface CatalystStatusMenuItem ()
@property (readonly, nonatomic) id systemStatusBar;
@property (readonly, nonatomic) id button;
@end

@implementation CatalystStatusMenuItem

- (instancetype)init {
    self = [self initWithLength:CatalystStatusMenuItemVariableLength];
    return self;
}

- (instancetype)initWithLength:(CGFloat)length {
    if (self = [super init]) {
        id nsStatusItem = ((id (*)(id, SEL, CGFloat))objc_msgSend)(self.systemStatusBar, NSSelectorFromString(@"statusItemWithLength:"), length);
        self.nsStatusItem = nsStatusItem;
    }
    
    return self;
}

- (void)dealloc {
    ((void (*)(id, SEL, id))objc_msgSend)(self.systemStatusBar, NSSelectorFromString(@"removeStatusItem:"), self.nsStatusItem);
}

- (void)setSystemSymbolName:(NSString *)name accessibilityDescription:(NSString *)description {
    id systemImage = ((id (*)(id, SEL, NSString *, NSString * _Nullable))objc_msgSend)(NSClassFromString(@"NSImage"), NSSelectorFromString(@"imageWithSystemSymbolName:accessibilityDescription:"), name, description);
    ((void (*)(id ,SEL, NSImage *))objc_msgSend)(self.button, NSSelectorFromString(@"setImage:"), systemImage);
}

- (id)systemStatusBar {
    return ((id (*)(id, SEL))objc_msgSend)(NSClassFromString(@"NSStatusBar"), @selector(systemStatusBar));
}

- (id)button {
    id button = ((id (*)(id, SEL))objc_msgSend)(self.nsStatusItem, NSSelectorFromString(@"button"));
    return button;
}

@end

#endif
