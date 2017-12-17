//
//  JTMonkeyRouterProtocol.h
//  JTMonkeyRouter
//
//  Created by Jammy Tang on 2017/12/15.
//

#import <Foundation/Foundation.h>

@protocol JTMonkeyRouterProtocol <NSObject>

@property (nonatomic, strong) NSDictionary *monkeyRouterParameters;

@end

@protocol JTMonkeyEventProtocol <NSObject>

- (id)routerPerformWithEventId:(NSString *)eventId parameter:(NSDictionary *)parameter;

@end
