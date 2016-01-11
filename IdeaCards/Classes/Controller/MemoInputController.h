#import <UIKit/UIKit.h>

@class ICMemo;

@interface MemoInputController : UIViewController

@property(nonatomic) id delegate;
@property(nonatomic,retain) NSString *leftItem;
@property(nonatomic,retain) NSString *rightItem;

- (id)initWithMemo:(ICMemo *)memo;

@end

@protocol MemoInputControllerDelegate <NSObject>

- (void)memoInputControllerDidFinish:(MemoInputController *)controller;

@end
