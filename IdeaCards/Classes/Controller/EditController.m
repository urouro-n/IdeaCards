#import "EditController.h"
#import "AppDelegate.h"
#import "TopController.h"
#import "ICItemManager.h"

@interface EditController ()
<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property(nonatomic,retain) UITableView *table;
@property(nonatomic,retain) UITextField *addField;
@property(nonatomic,retain) UIButton *addButton;
@property(nonatomic,retain) UIView *addView;

@end

@implementation EditController


#pragma mark - View Lifecycle

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Table View
    CGRect frame;
    if(self.type == EditTypeRight){
        if((self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)){
            frame = CGRectMake(30,
                               0,
                               self.view.frame.size.height-30,
                               self.view.frame.size.width);
            
        }else{
            frame = CGRectMake(30,
                               0,
                               self.view.frame.size.width-30,
                               self.view.frame.size.height);
            
        }
        
    }else{
        if((self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)){
            frame = CGRectMake(0,
                               0,
                               self.view.frame.size.height-30,
                               self.view.frame.size.width);
            
        }else{
            frame = CGRectMake(0,
                               0,
                               self.view.frame.size.width-30,
                               self.view.frame.size.height);
            
        }
    }
    
    self.table = [[UITableView alloc] initWithFrame:frame
                                              style:UITableViewStylePlain];
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];
    
    
    // Input
    UIView *buttonView = [UIView new];
    buttonView.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    buttonView.backgroundColor = [UIColor clearColor];
    
    self.addField = [UITextField new];
    if(self.type == EditTypeRight){
        self.addField.frame = CGRectMake(40, 5, 220, 34);
    }else{
        self.addField.frame = CGRectMake(0, 5, 220, 34);
    }
    self.addField.delegate = self;
    self.addField.borderStyle = UITextBorderStyleRoundedRect;
    self.addField.returnKeyType = UIReturnKeyDone;
    [buttonView addSubview:self.addField];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(self.addField.frame.origin.x + self.addField.frame.size.width, 0, 44, 44);
    button.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:32.0f];
    button.titleEdgeInsets = UIEdgeInsetsMake(-5.0f, 0.0f, 0.0f, 0.0f);
    [button setTitle:@"+" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor clearColor]];
    button.titleLabel.shadowColor = [UIColor blackColor];
    button.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f);
    [button addTarget:self action:@selector(onAddButton:) forControlEvents:UIControlEventTouchUpInside];
    [buttonView addSubview:button];
    self.addButton = button;
    
    UIBarButtonItem *addItem = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    self.navigationItem.leftBarButtonItem = addItem;
    
    self.addView = buttonView;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [self orientationChanged:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}


#pragma mark - Action

- (void)onAddButton:(UIBarButtonItem *)button
{
    [self.addField resignFirstResponder];
    
    [self _add];
}


#pragma mark - Notification

- (void)orientationChanged:(NSNotification *)notification
{
    if(self.interfaceOrientation == UIInterfaceOrientationPortrait ||
       self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        if(self.type == EditTypeRight){
            self.table.frame = CGRectMake(30,
                                          0,
                                          320-30,
                                          480);
            
            self.addField.frame = CGRectMake(40, 5, 220, 34);
            
        }else{
            self.table.frame = CGRectMake(0,
                                          0,
                                          320-30,
                                          480);
            
            self.addField.frame = CGRectMake(0, 5, 220, 34);
        }
        
        self.addButton.frame = CGRectMake(self.addField.frame.origin.x + self.addField.frame.size.width, 0, 44, 44);
        self.addView.frame = CGRectMake(0, 0, 320, 44);
        
    }else{
        
        if(self.type == EditTypeRight){
            self.table.frame = CGRectMake(48,
                                          0,
                                          480-48,
                                          320);
            
            self.addField.frame = CGRectMake(48, 8, 350, 26);
            
        }else{
            self.table.frame = CGRectMake(0,
                                          0,
                                          480-48,
                                          320);
            
            self.addField.frame = CGRectMake(0, 8, 350, 26);
            
        }
        
        self.addButton.frame = CGRectMake(self.addField.frame.origin.x + self.addField.frame.size.width, 0, 44, 44);
        self.addView.frame = CGRectMake(0, 0, 480, 44);
        
    }
}


#pragma mark - UITableView DataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.type == EditTypeRight){
        return [[[ICItemManager sharedManager] rightItems] count];
    }else{
        return [[[ICItemManager sharedManager] leftItems] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    
    NSArray *items;
    if(self.type == EditTypeRight){
        items = [[ICItemManager sharedManager] rightItems];
    }else{
        items = [[ICItemManager sharedManager] leftItems];
    }
    
    cell.textLabel.text = [items objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.type == EditTypeRight){
        [[ICItemManager sharedManager] deleteRightItemAtIndex:indexPath.row];
    }else{
        [[ICItemManager sharedManager] deleteLeftItemAtIndex:indexPath.row];
    }
    
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                     withRowAnimation:UITableViewRowAnimationFade];
    
    [self _reloadData];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


#pragma mark - UITextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    [self _add];
    
    return YES;
}


#pragma mark -

- (void)_reloadData
{
    [self.table reloadData];
    
    // メイン画面のデータも更新
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(appDelegate){
        UINavigationController *navController = (UINavigationController *)appDelegate.basePanelController.centerPanel;
        TopController *topController = (TopController *)[navController.viewControllers objectAtIndex:0];
        
        if([topController respondsToSelector:@selector(reloadData)]){
            [topController reloadData];
        }
    }
}

- (void)_add
{
    if([self.addField.text length] <= 0){
        return;
    }
    
    if(self.type == EditTypeRight){
        [[ICItemManager sharedManager] addRightItem:self.addField.text];
    }else{
        [[ICItemManager sharedManager] addLeftItem:self.addField.text];
    }
    
    self.addField.text = nil;
    
    [self _reloadData];
}

@end
