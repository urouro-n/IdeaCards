#import "MemoListController.h"
#import "MemoInputController.h"
#import "ICDaoMemo.h"

@interface MemoListController ()
<UITableViewDelegate, UITableViewDataSource, MemoInputControllerDelegate, UIActionSheetDelegate, MFMailComposeViewControllerDelegate>

@property(nonatomic,retain) UITableView *table;
@property(nonatomic,retain) NSArray *data;
@property(nonatomic,retain) UIActionSheet *sheet;
@property(nonatomic,retain) ICMemo *sheetTemporaryMemo;

@end

@implementation MemoListController


#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    // Table View
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                               0,
                                                               self.view.frame.size.width,
                                                               self.view.frame.size.height-44)
                                              style:UITableViewStylePlain];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];
    
    // TableView Long Press
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self                                                                                                   action:@selector(handleTableLongPress:)];
    longPressGesture.minimumPressDuration = 0.5f;
    [self.table addGestureRecognizer:longPressGesture];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self _reloadData];
}


#pragma mark - Action

- (void)onCloseButton:(UIBarButtonItem *)button
{
    if([self.delegate respondsToSelector:@selector(memoListControllerDidFinish:)]){
        [self.delegate memoListControllerDidFinish:self];
    }
}


#pragma mark - Gesture

- (void)handleTableLongPress:(UILongPressGestureRecognizer *)recognizer
{
    LOG_METHOD;
    
    CGPoint point = [recognizer locationInView:self.table];
    NSIndexPath *indexPath = [self.table indexPathForRowAtPoint:point];
    
    if(indexPath){
        ICMemo *memo = [self.data objectAtIndex:indexPath.row];
        self.sheetTemporaryMemo = memo;
        
        if(!self.sheet){
            self.sheet = [[UIActionSheet alloc] initWithTitle:memo.text
                                                     delegate:self
                                            cancelButtonTitle:@"キャンセル"
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:
                          @"メール",   // 0
                          @"Twitter", // 1
                          nil];
            [self.sheet showInView:self.view];
        }
    }
}


#pragma mark - UITableView DataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:CellIdentifier];
    }
    
    ICMemo *memo = [self.data objectAtIndex:indexPath.row];
    cell.textLabel.text = memo.text;
    cell.detailTextLabel.text = memo.theme;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ICMemo *memo = [self.data objectAtIndex:indexPath.row];
    
    MemoInputController *controller;
    controller = [[MemoInputController alloc] initWithMemo:memo];
    controller.delegate = self;
    
    UINavigationController* navController;
    navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentModalViewController:navController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    ICMemo *memo = [self.data objectAtIndex:indexPath.row];
    
    BOOL rs = NO;
    rs = [[ICDaoMemo defaultInstance] deleteMemo:memo];
    
    if(!rs){
        LOG(@"rs=%@", (rs)?@"YES":@"NO");
    }
    
    [self _reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)_reloadData
{
    self.data = [[ICDaoMemo defaultInstance] selectMemos];
    
    [self.table reloadData];
}


#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    LOG(@"buttonIndex=%d", buttonIndex);
    
    if(buttonIndex == 0){
        // メール
        
        if(self.sheetTemporaryMemo){
            [self _sendMail:[NSString stringWithFormat:@"アイデア: %@", self.sheetTemporaryMemo.theme]
                       body:[NSString stringWithFormat:@"%@<br /><br />%@<br /><br />%@<br /><a href='%@'>%@</a>",
                             self.sheetTemporaryMemo.theme,
                             self.sheetTemporaryMemo.text,
                             APP_NAME,
                             APP_URL,
                             APP_URL]];
        }
        
    }else if(buttonIndex == 1){
        // Twitter
        
        if(self.sheetTemporaryMemo){
            [self _sendTwitter:[NSString stringWithFormat:@"%@ → %@ %@ %@",
                                self.sheetTemporaryMemo.theme,
                                self.sheetTemporaryMemo.text,
                                APP_HASHTAG,
                                APP_URL]];
        }
    }
    
    self.sheet = nil;
    self.sheetTemporaryMemo = nil;
}


#pragma mark - MFMailComposeViewController Delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultCancelled:
            break;
            
        case MFMailComposeResultSaved:
            break;
            
        case MFMailComposeResultSent:
            break;
            
        case MFMailComposeResultFailed:
            break;
            
        default:
            break;
    }
    
    [controller dismissModalViewControllerAnimated:YES];
}


#pragma mark - MemoInputController Delegate

- (void)memoInputControllerDidFinish:(MemoInputController *)controller
{
    [controller dismissModalViewControllerAnimated:YES];
    
    [self _reloadData];
}


#pragma mark - Private Methods

- (void)_sendMail:(NSString *)title body:(NSString *)body
{
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:title];
    [picker setMessageBody:body isHTML:YES];
    
    [self presentModalViewController:picker animated:YES];
}

- (void)_sendTwitter:(NSString *)body
{
    // TODO: Replace to Social framework
//    TWTweetComposeViewController *controller = [TWTweetComposeViewController new];
//    [controller setInitialText:body];
//    
//    controller.completionHandler = ^(TWTweetComposeViewControllerResult result) {
//        if(result == TWTweetComposeViewControllerResultCancelled){
//            LOG(@"cancel");
//        }else if(result == TWTweetComposeViewControllerResultDone){
//            LOG(@"success");
//        }
//        
//        [self dismissModalViewControllerAnimated:YES];
//    };
//    
//    [self presentModalViewController:controller animated:YES];
}

@end
