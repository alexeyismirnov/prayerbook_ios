//
//  DailyViewController.m
//  prayerbook
//
//  Created by Alexey Smirnov on 9/10/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

#import "DailyViewController.h"
#import "MyLanguage.h"
#import "PrayerViewController.h"
#import "OptionsTableViewController.h"

@interface DailyViewController ()

@end

@implementation DailyViewController
{
    NSArray *titles;
}

- (void)reload
{
    titles = [MyLanguage tableViewStrings:@"daily"];
    [self.tableView reloadData];
}

- (void) optionsSaved:(NSNotification *)paramNotification
{
    [self reload];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)addRoundedBorder:(UIButton*)button
{
    UIColor *color = self.view.tintColor;

    [button.layer setBorderColor:[color CGColor]];
    [button.layer setBorderWidth:1.0f];
    [button.layer setCornerRadius:10];
    [button setTitleColor:color forState:UIControlStateNormal];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self addRoundedBorder:self.foodButton];
    [self addRoundedBorder:self.buttonLeft];
    [self addRoundedBorder:self.buttonRight];
    
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                      attribute:NSLayoutAttributeLeading
                                                                      relatedBy:0
                                                                         toItem:self.view
                                                                      attribute:NSLayoutAttributeLeft
                                                                     multiplier:1.0
                                                                       constant:10];
    [self.view addConstraint:leftConstraint];
    
    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.tableView
                                                                       attribute:NSLayoutAttributeTrailing
                                                                       relatedBy:0
                                                                          toItem:self.view
                                                                       attribute:NSLayoutAttributeRight
                                                                      multiplier:1.0
                                                                        constant:-10];
    [self.view addConstraint:rightConstraint];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(optionsSaved:)
     name:OPTIONS_SAVED_NOTIFICATION
     object:nil];

    [self reload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Prayer"]) {
        PrayerViewController *view = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        view.index = indexPath.row;
        view.code = @"daily";
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    else
        return [titles count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return @"Daily Gospel";
    else
        return @"Daily prayers";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }

    if (indexPath.section == 0)
        cell.textLabel.text = @"Luke 2:3-4";
    else
        cell.textLabel.text = [titles objectAtIndex:indexPath.row];

    return cell;
}

@end
