//
//  AppDelegate.m
//  ShootTheTank
//
//  Created by Westley Rose on 2/6/21.
//

#import "AppDelegate.h"

@implementation AppDelegate

NSTask* hostingTask = nil;

+ (void)setHostingTask:(NSTask*)task {
    hostingTask = task;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    NSLog(@"%s", __func__);

    [hostingTask terminate];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

@end
