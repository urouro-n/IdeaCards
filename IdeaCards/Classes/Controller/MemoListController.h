#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <Twitter/Twitter.h>

@interface MemoListController : UIViewController

@property(nonatomic) id delegate;

@end

@protocol MemoListControllerDelegate <NSObject>

- (void)memoListControllerDidFinish:(MemoListController *)controller;

@end
