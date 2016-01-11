#import "ICDaoMemo.h"
#import "FMDatabase.h"

#define DB_FILE_NAME @"memo.db"

@implementation ICDaoMemo


#pragma mark - Initialize

static ICDaoMemo *_sharedInstance = nil;

+ (ICDaoMemo *)defaultInstance
{
    if(!_sharedInstance){
        _sharedInstance = [[ICDaoMemo alloc] init];
    }
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if(!self){
        return nil;
    }
    
    [self _init];
    
    return self;
}

- (void)_init
{
    [self _createTable];
}


#pragma mark - DB

- (BOOL)insertWithMemo:(ICMemo *)memo
{
    NSString *sqlInsert =
    @"INSERT INTO memo \
    (theme, text, date) \
    VALUES \
    (?, ?, ?) \
    ;";
    
    FMDatabase *db = [self _dbConnection];
    [db open];
    [db setShouldCacheStatements:YES];
    
    BOOL rs = [db executeUpdate:sqlInsert,
               memo.theme,
               memo.text,
               [NSDate date]];
    
    LOG(@"rs=%@", (rs)?@"YES":@"NO");
    if(!rs) LOG(@"error=%@", [db lastError]);
    
    [db close];
    
    return rs;
}

- (NSArray *)selectMemos
{
    NSString *sqlSelectChart = @"SELECT * FROM memo";
    
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:0];
    
    FMDatabase *db = [self _dbConnection];
    [db open];
    
    FMResultSet *rs = [db executeQuery:sqlSelectChart];
    
    while([rs next]){
        ICMemo *memo = [[ICMemo alloc] init];
        memo.memoId = [rs intForColumnIndex:0];
        memo.theme = [rs stringForColumnIndex:1];
        memo.text = [rs stringForColumnIndex:2];
        
        LOG(@"%@", memo);
        
        [resultArray addObject:memo];
    }
    
    return resultArray;
}

- (NSInteger)countMemos
{
    NSInteger count;
    
    NSString *sqlSelectChart = @"SELECT COUNT(*) FROM memo";
    
    FMDatabase *db = [self _dbConnection];
    [db open];
    
    FMResultSet *rs = [db executeQuery:sqlSelectChart];
    
    while([rs next]){
        count = [rs intForColumnIndex:0];
        LOG(@"count=%d", count);
    }
    
    return count;
}

- (BOOL)deleteAllMemos
{
    FMDatabase *db = [self _dbConnection];
    NSString *sql = @"DELETE FROM memo";
    
    [db open];
    BOOL rs = [db executeUpdate:sql];
    [db close];
    
    LOG(@"rs=%@", (rs)?@"YES":@"NO");
    if(!rs) LOG(@"error=%@", [db lastError]);
    
    return rs;
}

- (BOOL)deleteMemo:(ICMemo *)memo
{
    if(memo.memoId <= 0){
        return NO;
    }
    
    FMDatabase *db = [self _dbConnection];
    NSString *sql = @"DELETE FROM memo WHERE memo_id = ?";
    
    [db open];
    BOOL rs = [db executeUpdate:sql, [NSNumber numberWithInt:memo.memoId]];
    [db close];
    
    LOG(@"rs=%@", (rs)?@"YES":@"NO");
    if(!rs) LOG(@"error=%@", [db lastError]);
    
    return rs;
}

- (BOOL)updateWithMemo:(ICMemo *)memo
{
    //Item IDが不正な場合
    if(memo.memoId <= 0){
        return NO;
    }
    
    NSString *sqlUpdate =
    @"UPDATE memo SET \
    theme = ?,\
    text = ?,\
    date = ? \
    WHERE memo_id = ?";
    
    FMDatabase *db = [self _dbConnection];
    [db open];
    [db setShouldCacheStatements:YES];
    
    BOOL rs = [db executeUpdate:sqlUpdate,
               memo.theme,
               memo.text,
               [NSDate date],
               [NSNumber numberWithInt:memo.memoId]];
    
    LOG(@"rs=%@", (rs)?@"YES":@"NO");
    if(!rs) LOG(@"error=%@", [db lastError]);
    
    [db close];
    
    return rs;
}


#pragma mark - Private Methods

- (BOOL)_createTable
{
    LOG_METHOD;
    
    NSString *sqlItemTbl =
    @"CREATE TABLE IF NOT EXISTS memo ( \
    memo_id     INTEGER PRIMARY KEY AUTOINCREMENT, \
    theme       TEXT, \
    text        TEXT, \
    date        DATETIME \
    );";
    
    FMDatabase *db = [self _dbConnection];
    [db open];
    BOOL rs = [db executeUpdate:sqlItemTbl];
    [db close];
    
    LOG(@"rs=%@", (rs)?@"YES":@"NO");
    
    return rs;
}

- (FMDatabase *)_dbConnection
{
    if(!self.dbPath){
        self.dbPath = [self _pathWithFileName:DB_FILE_NAME];
    }
    
    FMDatabase *db = [FMDatabase databaseWithPath:self.dbPath];
    
    return db;
}

- (NSString *)_pathWithFileName:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *directory = [paths objectAtIndex:0];
    NSString *path = [directory stringByAppendingPathComponent:fileName];
    
    return path;
}

@end
