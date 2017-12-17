//
//  JTMonkeyRouter.m
//  JTMonkeyRouter
//
//  Created by Jammy Tang on 2017/12/14.
//

#import "JTMonkeyRouter.h"
#import <objc/runtime.h>
#import <objc/objc.h>
#import "JTMonkeyRouterProtocol.h"
#import "UIViewController+JTMonkeyFinder.h"

@interface JTMonkeyRouter ()

@property (nonatomic, strong) NSMutableArray *canRouterClassArray;
@property (nonatomic, strong) NSMutableArray *canEventClassArray;

@end

@implementation JTMonkeyRouter

+ (instancetype)sharedInstance {
    static JTMonkeyRouter *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JTMonkeyRouter alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupClassArray];
    }
    return self;
}

- (void)setupClassArray {
    NSMutableArray *canRouterClassArray = [NSMutableArray arrayWithCapacity:100];
    NSMutableArray *canEventClassArray = [NSMutableArray arrayWithCapacity:100];
    Class *classes = NULL;
    int numClasses = objc_getClassList(NULL, 0);
    if (numClasses > 0) {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) *numClasses);
        numClasses = objc_getClassList(classes, numClasses);

        Class class = nil;
        for (int i = 0; i < numClasses; i++) {
            class = classes[i];
            if ([class conformsToProtocol:@protocol(JTMonkeyRouterProtocol)] && [class isKindOfClass:[UIViewController class]]) {
                NSString *className = [NSString stringWithCString:class_getName(class) encoding:NSUTF8StringEncoding];
                [canRouterClassArray addObject:className];
            }
            if ([class conformsToProtocol:@protocol(JTMonkeyEventProtocol)]) {
                NSString *className = [NSString stringWithCString:class_getName(class) encoding:NSUTF8StringEncoding];
                [canEventClassArray addObject:className];
            }
        }
        self.canRouterClassArray = canRouterClassArray;
        self.canEventClassArray = canEventClassArray;
        free(classes);
    }
}

- (void)performUrl:(NSString *)url {
    [self performUrl:url parameter:nil complete:nil];
}

- (void)performUrl:(NSString *)url parameter:(NSDictionary *)parameter {
    [self performUrl:url parameter:parameter complete:nil];
}

- (void)performUrl:(NSString *)url parameter:(NSDictionary *)parameter complete:(void(^)(NSDictionary *parameter))complete {
    if (![url hasPrefix:@"jt://"]) {
        if (complete) {
            complete(@{@"Error":[NSError errorWithDomain:@"Invalid url" code:-1 userInfo:@{}]});
        }
        [NSException raise:@"Invalid url" format:@"scheme does not matched."];
    }

    NSString *path = [url substringFromIndex:[@"jt://" length]];
    NSArray *components = [path componentsSeparatedByString:@"/"];
    if (components.count != 2) {
        if (complete) {
            complete(@{@"Error":[NSError errorWithDomain:@"Invalid url" code:-1 userInfo:@{}]});
        }
        [NSException raise:@"Invalid url" format:@"\"%@\" not an avaliable url.",url];
    }
    NSString *modular = components[0];

    UIViewController *viewController = (UIViewController *)[[NSClassFromString(modular) alloc] init];
    ((UIViewController <JTMonkeyRouterProtocol>*)viewController).monkeyRouterParameters = parameter;

    BOOL animation = NO;
    id animationObj = [parameter objectForKey:@"animation"];
    if ([animationObj isKindOfClass:[NSNumber class]]) {
        animation = [(NSNumber *)animationObj boolValue];
    }

    NSString *target = components[1];
    if ([target isEqualToString:@"push"]) {
        [[[UIApplication sharedApplication].delegate.window.rootViewController getTopNavigationController] pushViewController:viewController animated:animation];
        if (complete) {
            complete(nil);
        }
    }
    else if ([target isEqualToString:@"present"]) {
        if (![viewController isKindOfClass:[UINavigationController class]]) {
            viewController = [[UINavigationController alloc] initWithRootViewController:viewController];
        }
        [[[UIApplication sharedApplication].delegate.window.rootViewController getTopNavigationController] presentViewController:viewController animated:animation completion:^{
            if (complete) {
                complete(nil);
            }
        }];
    }
    else {
        if (complete) {
            complete(@{@"Error":[NSError errorWithDomain:@"target Invalid" code:-1 userInfo:@{}]});
        }
        [NSException raise:@"Target Invalied." format:@"The target is invalid."];
    }
}

- (void)sendEvent:(NSString *)eventUrl {
    [self sendEvent:eventUrl parameter:nil];
}

- (void)sendEvent:(NSString *)eventUrl parameter:(NSDictionary *)parameter {
    [self sendEvent:eventUrl parameter:parameter complete:nil];
}

- (void)sendEvent:(NSString *)eventUrl parameter:(NSDictionary *)parameter complete:(void(^)(NSDictionary *parameter))complete {
    [self sendEvent:eventUrl parameter:parameter complete:complete];
}

- (void)sendEvent:(NSString *)eventUrl parameter:(NSDictionary *)parameter complete:(void (^)(NSDictionary *))complete sync:(BOOL)sync {
    if (![eventUrl hasPrefix:@"jt://"]) {
        if (complete) {
            complete(@{@"Error":[NSError errorWithDomain:@"Invalid url" code:-1 userInfo:@{}]});
        }
        [NSException raise:@"Invalid url" format:@"scheme does not matched."];
    }

    NSString *path = [eventUrl substringFromIndex:[@"jt://" length]];
    NSArray *components = [path componentsSeparatedByString:@"/"];
    if (components.count != 2) {
        if (complete) {
            complete(@{@"Error":[NSError errorWithDomain:@"Invalid url" code:-1 userInfo:@{}]});
        }
        [NSException raise:@"Invalid url" format:@"\"%@\" not an avaliable url.", eventUrl];
    }
    NSString *modular = components[0];

    id<JTMonkeyEventProtocol> modularObjc = [[NSClassFromString(modular) alloc] init];

    if (![modularObjc conformsToProtocol:@protocol(JTMonkeyEventProtocol)]) {
        if (complete) {
            complete(@{@"Error":[NSError errorWithDomain:@"modular Invalid" code:-1 userInfo:@{}]});
        }
        [NSException raise:@"modular Invalied." format:@"The modular is invalid."];
    }

    NSString *target = components[1];
    if (target.length > 0) {
        [modularObjc routerPerformWithEventId:target parameter:parameter];
        if (complete) {
            complete(nil);
        }
    }
    else {
        if (complete) {
            complete(@{@"Error":[NSError errorWithDomain:@"target Invalid" code:-1 userInfo:@{}]});
        }
        [NSException raise:@"Target Invalied." format:@"The target is invalid."];
    }
}

@end
