//
//  PrayerViewController.m
//  prayerbook
//
//  Created by Alexey Smirnov on 8/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

#import "PrayerViewController.h"
#import "MyLanguage.h"

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

    self.webView.paginationBreakingMode = UIWebPaginationBreakingModePage;
    self.webView.paginationMode = UIWebPaginationModeLeftToRight;

    [self.webView loadHTMLString:txt baseURL:nil ];
    
   // [[self.webView.subviews objectAtIndex:0] setScrollEnabled:NO];
    [[self.webView scrollView] setBounces:NO];

    UIScrollView *scroll = [self.webView scrollView];
    scroll.pagingEnabled = TRUE;
    
    // [[self.webView.subviews objectAtIndex:0] setBounces:NO];

}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self reload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
