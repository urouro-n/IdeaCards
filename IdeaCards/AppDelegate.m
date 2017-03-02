#import "AppDelegate.h"
#import "TopController.h"
#import <DeployGateSDK/DeployGateSDK.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSDictionary *env = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Env" ofType:@"plist"]];
    [[DeployGateSDK sharedInstance] launchApplicationWithAuthor:env[@"DeployGate"][@"Author"]
                                                            key:env[@"DeployGate"][@"APIKey"]];
    
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication annotation:(nonnull id)annotation
{
    return [[DeployGateSDK sharedInstance] handleOpenUrl:url sourceApplication:sourceApplication annotation:annotation];
}

@end
