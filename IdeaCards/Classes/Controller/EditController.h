#import <UIKit/UIKit.h>

typedef enum {
    EditTypeLeft,
    EditTypeRight,
} EditType;

@interface EditController : UIViewController

@property(nonatomic,assign) EditType type;

@end
