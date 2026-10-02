#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// 绑定原版官方包名
static NSString *const kTargetBundleID = @"com.gameloft.despicableme2";

@implementation NSBundle (FakeBundleID)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class cls = [NSBundle class];

        // 1. Hook [NSBundle bundleIdentifier]
        Method origIdent = class_getInstanceMethod(cls, @selector(bundleIdentifier));
        Method fakeIdent = class_getInstanceMethod(cls, @selector(hook_bundleIdentifier));
        if (origIdent && fakeIdent) {
            method_exchangeImplementations(origIdent, fakeIdent);
        }

        // 2. Hook [NSBundle objectForInfoDictionaryKey:] 防止直接读取 plist 键值
        Method origInfo = class_getInstanceMethod(cls, @selector(objectForInfoDictionaryKey:));
        Method fakeInfo = class_getInstanceMethod(cls, @selector(hook_objectForInfoDictionaryKey:));
        if (origInfo && fakeInfo) {
            method_exchangeImplementations(origInfo, fakeInfo);
        }
    });
}

- (NSString *)hook_bundleIdentifier {
    if (self == [NSBundle mainBundle]) {
        return kTargetBundleID;
    }
    return [self hook_bundleIdentifier];
}

- (id)hook_objectForInfoDictionaryKey:(NSString *)key {
    if (self == [NSBundle mainBundle] && [key isEqualToString:@"CFBundleIdentifier"]) {
        return kTargetBundleID;
    }
    return [self hook_objectForInfoDictionaryKey:key];
}

@end
