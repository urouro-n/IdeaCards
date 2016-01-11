#import "AppDelegate.h"
#import "TopController.h"
#import "EditController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    JASidePanelController *baseController = [[JASidePanelController alloc] init];
    TopController *topController = [[TopController alloc] init];
    EditController *leftController = [[EditController alloc] init];
    leftController.type = EditTypeLeft;
    EditController *rightController = [[EditController alloc] init];
    rightController.type = EditTypeRight;
    
    UINavigationController *topNav = [[UINavigationController alloc] initWithRootViewController:topController];
    [topNav setNavigationBarHidden:YES];
    UINavigationController *leftNav = [[UINavigationController alloc] initWithRootViewController:leftController];
    [leftNav setNavigationBarHidden:NO];
    UINavigationController *rightNav = [[UINavigationController alloc] initWithRootViewController:rightController];
    [rightNav setNavigationBarHidden:NO];
    
    baseController.leftPanel = leftNav;
    baseController.centerPanel = topNav;
    baseController.rightPanel = rightNav;
    
    baseController.leftGapPercentage = 0.9f;
    baseController.rightGapPercentage = 0.9f;
    
    self.window.rootViewController = baseController;
    self.basePanelController = baseController;
    
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
