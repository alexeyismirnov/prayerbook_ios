//
//  PrayerViewController.m
//  prayerbook
//
//  Created by Alexey Smirnov on 8/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

#import "PrayerViewController.h"
#import "MyLanguage.h"
#import "OptionsTableViewController.h"

@interface PrayerViewController ()

@end

@implementation PrayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)reload
{
    NSString *filename = [NSString stringWithFormat:@"prayer_%d_%d_%@.html", self.index.section, self.index.row, [MyLanguage language]];
    NSString *bundlename = [[NSBundle mainBundle] pathForResource:filename ofType:nil ];
    NSString *txt = [NSString stringWithContentsOfFile:bundlename encoding:NSUTF8StringEncoding error:NULL];

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int fontSize = [prefs integerForKey:@"fontSize"];

    txt = [txt stringByReplacingOccurrencesOfString:@"FONTSIZE"
                                         withString:[NSString stringWithFormat:@"%dpt", fontSize] ];

    self.webView.paginationBreakingMode = UIWebPaginationBreakingModePage;
    self.webView.paginationMode = UIWebPaginationModeLeftToRight;

    [self.webView loadHTMLString:txt baseURL:nil ];
    
    UIScrollView *scroll = [self.webView scrollView];
    scroll.pagingEnabled = TRUE;
    [scroll setBounces:FALSE];
}

- (void) optionsSaved:(NSNotification *)paramNotification
{
    [self reload];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reload];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(optionsSaved:)
     name:OPTIONS_SAVED_NOTIFICATION
     object:nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"Options"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        OptionsTableViewController *options = [navigationController viewControllers][0];
        options.delegate = self;
    }
}

@end
