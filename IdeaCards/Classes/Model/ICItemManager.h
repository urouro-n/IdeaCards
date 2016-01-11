#import <Foundation/Foundation.h>

@interface ICItemManager : NSObject

+ (ICItemManager *)sharedManager;

- (NSArray *)leftItems;
- (NSArray *)rightItems;

- (void)addLeftItem:(NSString *)item;
- (void)addRightItem:(NSString *)item;

- (void)deleteLeftItemAtIndex:(NSInteger)index;
- (void)deleteRightItemAtIndex:(NSInteger)index;

@end
