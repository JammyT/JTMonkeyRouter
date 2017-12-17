//
//  UIViewController+JTMonkeyFinder.m
//  JTMonkeyRouter
//
//  Created by Jammy Tang on 2017/12/16.
//

#import "UIViewController+JTMonkeyFinder.h"

@implementation UIViewController (JTMonkeyFinder)

- (UIViewController *)getTopViewController {
    if (self.presentedViewController) {
        return [self.presentedViewController getTopViewController];
    }
    else if ([self isKindOfClass:UINavigationController.class]) {
        return [[(UINavigationController *)self visibleViewController] getTopViewController];
    }
    return self;
}

- (UINavigationController *)getTopNavigationController {
    UIViewController *topViewController = [self getTopViewController];
    if (topViewController.navigationController) {
        return topViewController.navigationController;
    }
    return nil;
}

@end
