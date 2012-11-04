//
//  JJAppDelegate.m
//  AFAcceleratedDownloadRequestOperation-Sample
//
//  Created by Josh Johnson on 9/29/12.
//  Copyright (c) 2012 jnjosh.com. All rights reserved.
//

#import "JJAppDelegate.h"
#import "JJViewController.h"

@implementation JJAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[self.window setRootViewController:[[JJViewController alloc] initWithNibName:nil bundle:nil]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}
@end
