#import "TopController.h"
#import "MemoInputController.h"
#import "MemoListController.h"
#import "ICItemManager.h"
#import "iCarousel.h"
#import "AwesomeMenu.h"

@interface TopController ()
<iCarouselDataSource, iCarouselDelegate, MemoInputControllerDelegate, AwesomeMenuDelegate, MemoListControllerDelegate>

@property (nonatomic, copy) NSArray *leftData;
@property (nonatomic, copy) NSArray *rightData;

@property (nonatomic, weak) IBOutlet iCarousel *leftCarousel;
@property (nonatomic, weak) IBOutlet iCarousel *rightCarousel;
@property (nonatomic, weak) IBOutlet UIButton *crossButton;
@property (nonatomic, strong) AwesomeMenu *menu;
@property (nonatomic, strong) UIView *menuBackground;

@end

@implementation TopController

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.leftCarousel.delegate = self;
    self.leftCarousel.dataSource = self;
    self.leftCarousel.type = iCarouselTypeLinear;
    self.leftCarousel.vertical = YES;
    
    self.rightCarousel.delegate = self;
    self.rightCarousel.dataSource = self;
    self.rightCarousel.type = iCarouselTypeLinear;
    self.rightCarousel.vertical = YES;
    
    // Menu
    self.menu = [self _createMenu:CGPointMake(self.view.center.x, self.view.frame.size.height - 30)];
    [self.view addSubview:self.menu];
    
    self.menuBackground = [UIView new];
    self.menuBackground.frame = self.view.bounds;
    self.menuBackground.backgroundColor = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.5f];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemAdded:)
                                                 name:ICItemManagerDidAddItem
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(itemRemoved:)
                                                 name:ICItemManagerDidRemoveItem
                                               object:nil];
    
    [self reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ICItemManagerDidAddItem
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:ICItemManagerDidRemoveItem
                                                  object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}


#pragma mark - Action

- (IBAction)onCrossButton:(id)sender
{
    MemoInputController *controller;
    controller = [[MemoInputController alloc] init];
    controller.delegate = self;
    controller.leftItem = [self _itemCurrentIndex:self.leftCarousel];
    controller.rightItem = [self _itemCurrentIndex:self.rightCarousel];
    
    UINavigationController* navController;
    navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.modalPresentationStyle = UIModalPresentationFormSheet;
    
    [self presentModalViewController:navController animated:YES];
}


#pragma mark - Notification

- (void)orientationChanged:(NSNotification *)notification
{
    CGFloat height;
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    if(screenSize.width == 320.0 && screenSize.height == 568.0){
        height = 568;
    }else{
        height = 480;
    }
    
    if(self.interfaceOrientation == UIInterfaceOrientationPortrait ||
       self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        [self.leftCarousel removeFromSuperview];
        self.leftCarousel.frame = CGRectMake(0,
                                             0,
                                             320/2,
                                             height-20);
        [self.view addSubview:self.leftCarousel];
        [self.leftCarousel reloadData];
        
        [self.rightCarousel removeFromSuperview];
        self.rightCarousel.frame = CGRectMake(320/2,
                                              0,
                                              320/2,
                                              height-20);
        [self.view addSubview:self.rightCarousel];
        [self.rightCarousel reloadData];
        
        [self.menu removeFromSuperview];
        self.menu = nil;
        self.menu = [self _createMenu:CGPointMake(320/2, height-20 - 30)];
        [self.view addSubview:self.menu];
        
        self.menuBackground.frame = CGRectMake(0, 0, 320, height-20);
        
    }else{
        [self.leftCarousel removeFromSuperview];
        self.leftCarousel.frame = CGRectMake(0,
                                             0,
                                             height/2,
                                             300);
        [self.view addSubview:self.leftCarousel];
        [self.leftCarousel reloadData];
        
        [self.rightCarousel removeFromSuperview];
        self.rightCarousel.frame = CGRectMake(height/2,
                                              0,
                                              height/2,
                                              300);
        [self.view addSubview:self.rightCarousel];
        [self.rightCarousel reloadData];
        
        [self.menu removeFromSuperview];
        self.menu = nil;
        self.menu = [self _createMenu:CGPointMake(height/2, 300 - 30)];
        [self.view addSubview:self.menu];
        
        self.menuBackground.frame = CGRectMake(0, 0, height, 300);
        
    }
    
    self.crossButton.center = CGPointMake(self.view.center.x, self.view.center.y-5);
    [self.view bringSubviewToFront:self.crossButton];
}

- (void)itemAdded:(NSNotification *)notification
{
    [self reloadData];
}

- (void)itemRemoved:(NSNotification *)notification
{
    LOG(@"notification=%@", notification);
    
    [self reloadData];
}


#pragma mark - iCarousel DataSource/Delegate

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    if(carousel == self.leftCarousel){
        return [self.leftData count];
    }else{
        return [self.rightData count];
    }
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    UILabel *label = nil;
    CGRect viewFrame = CGRectMake(0, 0, self.view.frame.size.width/2, self.view.frame.size.width/2);
    CGSize labelSize = CGSizeMake(viewFrame.size.width-20, viewFrame.size.height-20);
    
    if(view == nil){
        view = [[UIImageView alloc] initWithFrame:viewFrame];
        view.contentMode = UIViewContentModeCenter;
        view.backgroundColor = [UIColor whiteColor];
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelSize.width, labelSize.height)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = UITextAlignmentCenter;
        label.font = [label.font fontWithSize:25];
        label.tag = 1;
        label.numberOfLines = 0;
        [view addSubview:label];
        
    }else{
        label = (UILabel *)[view viewWithTag:1];
    }
    
    if(carousel == self.leftCarousel){
        label.text = [self.leftData objectAtIndex:index];
        [label sizeThatFits:labelSize];
        label.center = CGPointMake(view.frame.size.width/2-5, view.frame.size.height/2);
    }else{
        label.text = [self.rightData objectAtIndex:index];
        [label sizeThatFits:labelSize];
        label.center = CGPointMake(view.frame.size.width/2+5, view.frame.size.height/2);
    }
    
    
    return view;
}

- (CGFloat)carousel:(iCarousel *)_carousel valueForOption:(iCarouselOption)option withDefault:(CGFloat)value
{
    if(option == iCarouselOptionWrap){
        return YES;
    }else{
        return value;
    }
}

- (NSString *)_itemCurrentIndex:(iCarousel *)carousel
{
    UILabel *label = (UILabel *)[[carousel currentItemView] viewWithTag:1];
    return label.text;
}


#pragma mark - AwesomeMenu Delegate

- (void)AwesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx
{
    if(idx == 7){
        MemoListController *controller;
        controller = [[MemoListController alloc] init];
        controller.delegate = self;
        
        UINavigationController* navController;
        navController = [[UINavigationController alloc] initWithRootViewController:controller];
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        
        [self presentModalViewController:navController animated:YES];
    }
    
    [self _menuBackground:NO];
}

- (void)AwesomeMenuWillBeganAnimation:(AwesomeMenu *)menu
{
    [self _menuBackground:menu.isExpanding];
}


#pragma mark - MemoInputController Delegate

- (void)memoInputControllerDidFinish:(MemoInputController *)controller
{
    [controller dismissModalViewControllerAnimated:YES];
}


#pragma mark - MemoListController Delegate

- (void)memoListControllerDidFinish:(MemoListController *)controller
{
    [controller dismissModalViewControllerAnimated:YES];
}


#pragma mark - Private Methods

- (void)reloadData
{
    self.leftData = nil;
    self.rightData = nil;
    
    NSArray *left = [[ICItemManager sharedManager] leftItems];
    NSArray *right = [[ICItemManager sharedManager] rightItems];
    
    NSMutableArray *tempLeftArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *tempRightArray = [NSMutableArray arrayWithCapacity:0];
    
    for(int i=0; i<10; i++){
        [tempLeftArray addObjectsFromArray:left];
        [tempRightArray addObjectsFromArray:right];
    }
    
    self.leftData = [NSArray arrayWithArray:tempLeftArray];
    self.rightData = [NSArray arrayWithArray:tempRightArray];
    
    [self.leftCarousel reloadData];
    [self.rightCarousel reloadData];
}

- (AwesomeMenu *)_createMenu:(CGPoint)center
{
    UIImage *baseImage = [UIImage imageNamed:@"menu_item.png"];
    UIImage *baseOnImage = [UIImage imageNamed:@"menu_item_on.png"];
    UIImage *listItemImage = [UIImage imageNamed:@"menu_icon_list.png"];
    UIImage *settingItemImage = [UIImage imageNamed:@"menu_icon_gear.png"];
    UIImage *helpItemImage = [UIImage imageNamed:@"menu_icon_help.png"];
    
    AwesomeMenuItem *listItem = [[AwesomeMenuItem alloc] initWithImage:baseImage
                                                      highlightedImage:baseOnImage
                                                          ContentImage:listItemImage
                                               highlightedContentImage:nil];
    AwesomeMenuItem *settingItem = [[AwesomeMenuItem alloc] initWithImage:baseImage
                                                         highlightedImage:baseOnImage
                                                             ContentImage:settingItemImage
                                                  highlightedContentImage:nil];
    AwesomeMenuItem *helpItem = [[AwesomeMenuItem alloc] initWithImage:baseImage
                                                      highlightedImage:baseOnImage
                                                          ContentImage:helpItemImage
                                               highlightedContentImage:nil];
    AwesomeMenuItem *emptyItem = [[AwesomeMenuItem alloc] initWithImage:nil
                                                       highlightedImage:nil
                                                           ContentImage:nil
                                                highlightedContentImage:nil];
    
    AwesomeMenu *menu = [[AwesomeMenu alloc] initWithFrame:self.view.bounds
                                                     menus:[NSArray arrayWithObjects:
                                                            emptyItem, // idx=0
                                                            settingItem, // idx=1
                                                            emptyItem,
                                                            emptyItem,
                                                            emptyItem,
                                                            emptyItem,
                                                            emptyItem,
                                                            listItem,nil]]; // idx=7
    menu.startPoint = center;
    menu.delegate = self;
    menu.timeOffset = 0.001f;
    menu.farRadius = 90.0f;
    menu.nearRadius = 90.0f;
    menu.endRadius = 90.0f;
    menu.expandRotation = 0.0f;
    menu.closeRotation = 0.0f;
    
    return menu;
}

- (void)_menuBackground:(BOOL)show
{
    if(show){
        self.menuBackground.alpha = 0.0f;
        [self.view insertSubview:self.menuBackground belowSubview:self.menu];
        [UIView animateWithDuration:0.5f
                         animations:^{
                             self.menuBackground.alpha = 1.0f;
                         }];
        
    }else{
        [UIView animateWithDuration:0.5f
                         animations:^{
                             self.menuBackground.alpha = 0.0f;
                         } completion:^(BOOL f){
                             [self.menuBackground removeFromSuperview];
                         }];
    }
}


@end
