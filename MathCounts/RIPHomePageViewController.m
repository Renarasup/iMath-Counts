//
//  RIPHomePageViewController.m
//  Math Counts
//
//  Created by Tynan Douglas on 7/22/14.
//  Copyright (c) 2014 String Education. All rights reserved.
//

#import "RIPHomePageViewController.h"
#import "RIPSettingsViewController.h"
#import "RIPHistoryViewController.h"
#import "RIPTimeTestViewController.h"
#import "RIPMainMenuViewController.h"
#import "RIPTestConfigViewController.h"
#import "RIPDataManager.h"
#import "RIPSettingsManager.h"

@interface RIPHomePageViewController ()
<UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIAlertViewDelegate, UIToolbarDelegate, UIPopoverControllerDelegate>


@property (strong, nonatomic) UIBarButtonItem *backItem;
@property (strong, nonatomic) UIToolbar *settingsBar;
@property (strong, nonatomic) UIPopoverController *historyPopover;
@property (strong, nonatomic) UIPopoverController *settingsPopover;
@property (strong, nonatomic) UIPageViewController *pageController;
@property (strong, nonatomic) RIPMainMenuViewController *mvc;
@property (strong, nonatomic) RIPTestConfigViewController *tvc;
@property (nonatomic) BOOL operationChosen;

@end

#pragma mark

@implementation RIPHomePageViewController

#pragma mark Callback methods

- (void)showHistory:(id)sender
{
    //Displays history in a navigation controller

    RIPHistoryViewController *history = [[RIPHistoryViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:history];
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        navController.navigationBar.barStyle = UIBarStyleBlack;
        navController.navigationBar.translucent = YES;
        if (self.settingsPopover != nil)
            [self.settingsPopover dismissPopoverAnimated:YES];
        self.historyPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
        self.historyPopover.delegate = self;
        [self.historyPopover presentPopoverFromBarButtonItem:sender
                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                     animated:YES];
        
    } else
        [self presentViewController:navController animated:YES completion:nil];
}

- (void)showSettings:(id)sender
{
    RIPSettingsManager *dataManager = [RIPSettingsManager sharedManager];
    
    //Displays password prompt if one is set
    if (dataManager.password) {
        UIAlertView *passwordPrompt = [[UIAlertView alloc] initWithTitle:@"Enter Password"
                                                                 message:nil
                                                                delegate:self
                                                       cancelButtonTitle:@"Cancel"
                                                       otherButtonTitles:@"OK", nil];
        [passwordPrompt setAlertViewStyle:UIAlertViewStyleSecureTextInput];
        [passwordPrompt show];
    } else {
        //Displays settings in a navigation controller
        RIPSettingsViewController *settings = [[RIPSettingsViewController alloc] init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settings];
        navController.modalPresentationStyle = UIModalPresentationFullScreen;
        if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
            navController.navigationBar.barStyle = UIBarStyleBlack;
            navController.navigationBar.translucent = YES;
            if (self.historyPopover != nil)
                [self.historyPopover dismissPopoverAnimated:YES];
            self.settingsPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
            self.settingsPopover.delegate = self;
            [self.settingsPopover presentPopoverFromBarButtonItem:sender
                             permittedArrowDirections:UIPopoverArrowDirectionAny
                                             animated:YES];
        } else
            [self presentViewController:navController animated:YES completion:nil];
    }
}



- (void)goHome:(id)sender
{
    //Returns to operation selection
    __weak RIPHomePageViewController *weakSelf = self;
    if ([sender isKindOfClass:[NSNotification class]]) {
        self.operationChosen = NO;
        for (UIScrollView *view in self.pageController.view.subviews) {
            
            if ([view isKindOfClass:[UIScrollView class]]) {
                
                view.scrollEnabled = NO;
            }
        }
    }

    
    [self.pageController setViewControllers:@[self.mvc]
                                  direction:UIPageViewControllerNavigationDirectionReverse
                                   animated:YES
                                 completion:^(BOOL finished){
                                     
                                     RIPDataManager *sharedManager = [RIPDataManager sharedManager];
                                     RIPHomePageViewController *strongSelf = weakSelf;
                                     [strongSelf.mvc.view setNeedsDisplay];
                                     if ([sharedManager.operation isEqualToString:ADDITION]) {
                                         strongSelf.settingsBar.barTintColor = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:1.0];
                                         [strongSelf.mvc.addButton.button setSelected:YES];
                                     } else if ([sharedManager.operation isEqualToString:SUBTRACTION]) {
                                         strongSelf.settingsBar.barTintColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.7 alpha:1.0];
                                         [strongSelf.mvc.subtractButton.button setSelected:YES];
                                     } else if ([sharedManager.operation isEqualToString:MULTIPLICATION]) {
                                         strongSelf.settingsBar.barTintColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
                                         [strongSelf.mvc.multiplyButton.button setSelected:YES];
                                     } else if ([sharedManager.operation isEqualToString:DIVISION]) {
                                         strongSelf.settingsBar.barTintColor = [UIColor purpleColor];
                                         [strongSelf.mvc.divideButton.button setSelected:YES];
                                     } else {
                                         strongSelf.settingsBar.barTintColor = [UIColor darkGrayColor];
                                     }
                                     if (sharedManager.operation)
                                         strongSelf.navigationItem.title = sharedManager.operation;
                                     else
                                         strongSelf.navigationItem.title = @"Math Counts";
                                 }];
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)showBackButton:(id)sender
{
    //Displays back button if on second page
    self.backItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                     style:UIBarButtonItemStyleDone
                                                    target:self
                                                    action:@selector(goHome:)];
 
    self.navigationItem.leftBarButtonItem = self.backItem;
    self.navigationItem.rightBarButtonItem = self.tvc.startItem;
}

- (void)hideBackButton:(id)sender
{
    //Hides back button if on first page
    self.navigationItem.leftBarButtonItem = nil;
}

- (void)dismissPopover:(NSNotification *)note
{
    if ([note.object isKindOfClass:[RIPHistoryViewController class]])
        [self.historyPopover dismissPopoverAnimated:YES];
    else
        [self.settingsPopover dismissPopoverAnimated:YES];
}

- (void)startTest:(NSNotification *)note
{
    //Starts test from HomePageViewController in order to present via navigationController
    RIPTimeTestViewController *testViewController = [[RIPTimeTestViewController alloc] init];
    [self.navigationController pushViewController:testViewController animated:YES];
}

- (void)delayedSetOperation:(NSNotification *)note
{
    [self performSelector:@selector(setOperationTitle:) withObject:nil afterDelay:0.25];
}

- (void)setOperationTitle:(id)sender
{
    RIPDataManager *sharedManager = [RIPDataManager sharedManager];
    __weak RIPHomePageViewController *weakSelf = self;
    
    //Sets title to selected operation
    self.navigationItem.title = [NSString stringWithFormat:@"%@", [RIPDataManager sharedManager].operation];
    
    //Sets toolbar's color appropriately
    if ([sharedManager.operation isEqualToString:ADDITION])
        self.settingsBar.barTintColor = [UIColor colorWithRed:0.7 green:0.1 blue:0.1 alpha:1.0];
    else if ([sharedManager.operation isEqualToString:SUBTRACTION])
        self.settingsBar.barTintColor = [UIColor colorWithRed:0.0 green:0.3 blue:0.7 alpha:1.0];
    else if ([sharedManager.operation isEqualToString:MULTIPLICATION])
        self.settingsBar.barTintColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
    else if ([sharedManager.operation isEqualToString:DIVISION])
        self.settingsBar.barTintColor = [UIColor purpleColor];
    else
        self.settingsBar.barTintColor = [UIColor darkGrayColor];
    
    //Indicates an operation has been chosen and allows scrolling
    self.operationChosen = YES;
    for (UIScrollView *view in self.pageController.view.subviews) {
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            
            view.scrollEnabled = YES;
        }
    }
    //Refreshes UIPageViewController and TestConfigViewController
    self.tvc = [[RIPTestConfigViewController alloc] init];
    [self.pageController setViewControllers:@[self.tvc]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:YES
                                 completion:^(BOOL finished){
                                     RIPHomePageViewController *strongSelf = weakSelf;
                                     if (strongSelf.pageController.viewControllers[0] == strongSelf.tvc) {
                                         strongSelf.backItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                                                          style:UIBarButtonItemStyleDone
                                                                                         target:strongSelf
                                                                                         action:@selector(goHome:)];
                                         strongSelf.navigationItem.leftBarButtonItem = strongSelf.backItem;
                                         strongSelf.navigationItem.rightBarButtonItem = strongSelf.tvc.startItem;
                                     } else {
                                         strongSelf.navigationItem.leftBarButtonItem = nil;
                                         strongSelf.navigationItem.rightBarButtonItem = nil;
                                     }
                                 }];
}

- (void)setDefaultTitle:(NSNotification *)note
{
    //Sets default view options for if no operation is selected
    self.navigationItem.title = @"Math Counts";
    self.settingsBar.barTintColor = [UIColor darkGrayColor];
    self.operationChosen = NO;
    
    //Disables scrolling and refreshes pageViewController
    for (UIScrollView *view in self.pageController.view.subviews) {
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            
            view.scrollEnabled = NO;
        }
    }
    [self.pageController setViewControllers:@[self.mvc]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if ([popoverController isEqual:self.settingsPopover])
        self.settingsPopover = nil;
    else
        self.historyPopover = nil;
}

#pragma mark UIAlertView methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *inputPassword = [[alertView textFieldAtIndex:0] text];
    RIPSettingsManager *sharedManager = [RIPSettingsManager sharedManager];
    
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
    
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        
        //Displays settings if password is correct
        if ([inputPassword isEqualToString:sharedManager.password]) {
            RIPSettingsViewController *settings = [[RIPSettingsViewController alloc] init];
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:settings];
            navController.modalPresentationStyle = UIModalPresentationFullScreen;
            if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
                navController.navigationBar.barStyle = UIBarStyleBlack;
                navController.navigationBar.translucent = YES;
                if (self.historyPopover != nil)
                    [self.historyPopover dismissPopoverAnimated:YES];
                self.settingsPopover = [[UIPopoverController alloc] initWithContentViewController:navController];
                self.settingsPopover.delegate = self;
                [self.settingsPopover presentPopoverFromBarButtonItem:self.settingsBar.items[3]
                                 permittedArrowDirections:UIPopoverArrowDirectionAny
                                                 animated:YES];
            } else
                [self presentViewController:navController animated:YES completion:nil];
        } else {
            UIAlertView *incorrectPassword = [[UIAlertView alloc] initWithTitle:@"Incorrect Password"
                                                                        message:nil
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
            [incorrectPassword show];
        }
    }
}

#pragma mark UIPageViewController methods

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    //Shows back button if on second page
    if (completed) {
        if (self.pageController.viewControllers[0] == self.tvc) {
            self.backItem = [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                                             style:UIBarButtonItemStyleDone
                                                            target:self
                                                            action:@selector(goHome:)];
            self.navigationItem.leftBarButtonItem = self.backItem;
            self.navigationItem.rightBarButtonItem = self.tvc.startItem;
        } else {
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem = nil;
        }
    }
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    if ([viewController isEqual:self.mvc] && self.operationChosen)
        return self.tvc;
    else
        return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    if ([viewController isEqual:self.tvc])
        return self.mvc;
    else
        return nil;
}

#pragma mark View related methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *settingsImage;
    UIImage *historyImage;
    UIBarButtonItem *settingsItem;
    UIBarButtonItem *historyItem;
    UIBarButtonItem *paddingItem;
    
    [[self view] setBackgroundColor:[UIColor colorWithRed:0.94 green:0.94 blue:0.96 alpha:1.0]];
    
    //Creates views to display and populates them in a UIPageViewController
    self.mvc = [[RIPMainMenuViewController alloc] init];
    self.tvc = [[RIPTestConfigViewController alloc] init];
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                                          navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                                        options:nil];
    self.pageController.dataSource = self;
    self.pageController.delegate = self;
    [self.pageController setViewControllers:@[self.mvc]
                                  direction:UIPageViewControllerNavigationDirectionForward
                                   animated:NO
                                 completion:nil];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.pageController.automaticallyAdjustsScrollViewInsets = NO;
    [[self.pageController view] setFrame:[[self view] bounds]];
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    
    //Disables scrolling by default
    for (UIScrollView *view in self.pageController.view.subviews) {
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            
            view.scrollEnabled = NO;
        }
    }
    
    self.navigationItem.title = @"Math Counts";

    
    //Initializes toolbar items
    settingsImage = [UIImage imageNamed:@"Settings"];
    historyImage = [UIImage imageNamed:@"History"];
    
    paddingItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                target:nil
                                                                action:nil];
    settingsItem = [[UIBarButtonItem alloc] initWithImage:settingsImage
                                                    style:UIBarButtonItemStylePlain
                                                   target:self
                                                   action:@selector(showSettings:)];
    historyItem = [[UIBarButtonItem alloc] initWithImage:historyImage
                                                   style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(showHistory:)];
    
    //Configures toolbar
    self.settingsBar = [[UIToolbar alloc] init];
    self.settingsBar.frame = CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44);
    self.settingsBar.barTintColor = [UIColor darkGrayColor];
    [self.settingsBar setItems:@[paddingItem, historyItem, paddingItem, settingsItem, paddingItem] animated:NO];
    [self.view addSubview:self.settingsBar];
    
    
    //Notifications posted by OperationButtons when enabled/disabled
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(delayedSetOperation:)
                                                 name:@"buttonEnabled"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setDefaultTitle:)
                                                 name:@"buttonDisabled"
                                               object:nil];
    
    //Notification posted by TestConfigViewController
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(startTest:)
                                                 name:@"startTest"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goHome:)
                                                 name:@"resultsShown"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dismissPopover:) name:@"dismissPopover"
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
