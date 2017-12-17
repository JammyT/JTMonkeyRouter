//
//  JTMonkeyRouter.h
//  JTMonkeyRouter
//
//  Created by Jammy Tang on 2017/12/14.
//

#import <Foundation/Foundation.h>

@interface JTMonkeyRouter : NSObject

+ (instancetype)sharedInstance;

- (void)performUrl:(NSString *)url;
- (void)performUrl:(NSString *)url parameter:(NSDictionary *)parameter;
- (void)performUrl:(NSString *)url parameter:(NSDictionary *)parameter complete:(void(^)(NSDictionary *parameter))complete;

- (void)sendEvent:(NSString *)eventUrl;
- (void)sendEvent:(NSString *)eventUrl parameter:(NSDictionary *)parameter;
- (void)sendEvent:(NSString *)eventUrl parameter:(NSDictionary *)parameter complete:(void(^)(NSDictionary *parameter))complete;
- (void)sendEvent:(NSString *)eventUrl parameter:(NSDictionary *)parameter complete:(void(^)(NSDictionary *parameter))complete sync:(BOOL)sync;
@end
