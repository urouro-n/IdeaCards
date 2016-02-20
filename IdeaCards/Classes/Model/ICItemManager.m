#import "ICItemManager.h"

NSString * const ICItemManagerDidAddItem = @"ICItemManagerDidAddItem";
NSString * const ICItemManagerDidRemoveItem = @"ICItemManagerDidRemoveItem";

NSString * const kLeftItems = @"kLeftItems";
NSString * const kRightItems = @"kRightItems";

@interface ICItemManager()

@property(nonatomic,retain) NSMutableArray *left;
@property(nonatomic,retain) NSMutableArray *right;

@end

@implementation ICItemManager

static ICItemManager *_sharedInstance = nil;

+ (ICItemManager *)sharedManager
{
    if(!_sharedInstance){
        _sharedInstance = [[ICItemManager alloc] init];
    }
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if(!self){
        return nil;
    }
    
    self.left = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kLeftItems]];
    self.right = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:kRightItems]];
    
    return self;
}

- (NSArray *)leftItems
{
    return [NSArray arrayWithArray:self.left];
}

- (NSArray *)rightItems
{
    return [NSArray arrayWithArray:self.right];
}

- (void)addLeftItem:(NSString *)item
{
    [self.left addObject:item];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.left forKey:kLeftItems];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ICItemManagerDidAddItem object:item];
}

- (void)addRightItem:(NSString *)item
{
    [self.right addObject:item];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.right forKey:kRightItems];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ICItemManagerDidAddItem object:item];
}

- (void)deleteLeftItemAtIndex:(NSInteger)index
{
    NSString *item = self.left[index];
    [self.left removeObjectAtIndex:index];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.left forKey:kLeftItems];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ICItemManagerDidRemoveItem object:item];
}

- (void)deleteRightItemAtIndex:(NSInteger)index
{
    NSString *item = self.right[index];
    [self.right removeObjectAtIndex:index];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.right forKey:kRightItems];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ICItemManagerDidRemoveItem object:item];
}

@end
