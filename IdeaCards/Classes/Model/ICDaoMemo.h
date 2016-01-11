#import <Foundation/Foundation.h>
#import "ICMemo.h"

@interface ICDaoMemo : NSObject

@property(nonatomic,retain) NSString *dbPath;

+ (ICDaoMemo *)defaultInstance;

- (BOOL)_createTable;

- (BOOL)insertWithMemo:(ICMemo *)memo;
- (NSArray *)selectMemos;
- (NSInteger)countMemos;

- (BOOL)updateWithMemo:(ICMemo *)memo;

- (BOOL)deleteAllMemos;
- (BOOL)deleteMemo:(ICMemo *)memo;

@end
