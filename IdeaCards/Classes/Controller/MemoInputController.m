#import "MemoInputController.h"
#import "ICDaoMemo.h"

@interface MemoInputController ()
<UITextViewDelegate>

@property(nonatomic,retain) UITextView *textView;
@property(nonatomic,retain) ICMemo *memo;

@end

@implementation MemoInputController


#pragma mark - Initialize

- (id)init
{
    self = [super init];
    if(!self){
        return nil;
    }
    
    [self _init];
    
    return self;
}

- (id)initWithMemo:(ICMemo *)memo
{
    self = [super init];
    if(!self){
        return nil;
    }
    
    [self _init];
    
    self.memo = memo;
    
    return self;
}

- (void)_init
{
    self.leftItem = @"";
    self.rightItem = @"";
}


#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // Navigation Bar
    UIBarButtonItem *okItem = [[UIBarButtonItem alloc] initWithTitle:@"OK"
                                                               style:UIBarButtonItemStyleBordered
                                                              target:self
                                                              action:@selector(onOkButton:)];
    self.navigationItem.rightBarButtonItem = okItem;
    
    UIBarButtonItem *closeItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                  style:UIBarButtonItemStyleBordered
                                                                 target:self
                                                                 action:@selector(onCloseButton:)];
    self.navigationItem.leftBarButtonItem = closeItem;
    
    // TextView
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0,
                                                                 self.view.frame.size.width,
                                                                 self.view.frame.size.height)];
    self.textView.delegate = self;
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.textView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if(self.memo.memoId){
        self.textView.text = self.memo.text;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(self.memo.memoId){
        self.title = self.memo.theme;
    }else{
        self.title = [NSString stringWithFormat:@"%@ × %@", self.leftItem, self.rightItem];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShowNotification:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHideNotification:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Action

- (void)onOkButton:(UIBarButtonItem *)button
{
    // 入力チェック
    if([self.textView.text length] <= 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"入力してください"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        
        return;
    }
    
    // 登録
    BOOL rs = NO;
    if(self.memo.memoId){
        // 更新
        self.memo.text = self.textView.text;
        
        rs = [[ICDaoMemo defaultInstance] updateWithMemo:self.memo];
        
    }else{
        // 新規
        ICMemo *memo = [[ICMemo alloc] init];
        memo.theme = [NSString stringWithFormat:@"%@×%@", self.leftItem, self.rightItem];
        memo.text = self.textView.text;
        
        rs = [[ICDaoMemo defaultInstance] insertWithMemo:memo];
    }
    
    if(!rs){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"登録に失敗しました"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"OK", nil];
        [alert show];
        
        return;
    }
    
    // 閉じる
    if([self.delegate respondsToSelector:@selector(memoInputControllerDidFinish:)]){
        [self.delegate memoInputControllerDidFinish:self];
    }
}

- (void)onCloseButton:(UIBarButtonItem *)button
{
    if([self.delegate respondsToSelector:@selector(memoInputControllerDidFinish:)]){
        [self.delegate memoInputControllerDidFinish:self];
    }
}


#pragma mark - Notification

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    CGRect bounds;
    bounds = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    [self _adjustTextViewHeight:bounds];
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    [self _adjustTextViewHeight:CGRectZero];
}


#pragma mark - UITextView Delegate

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}


#pragma mark - Private Methods

- (void)_adjustTextViewHeight:(CGRect)bounds
{
    CGRect frame = self.textView.frame;
    frame.size.height = self.view.frame.size.height - bounds.size.height;
    self.textView.frame = frame;
}

@end
