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

@interface DailyViewController ()

@end

@implementation DailyViewController
{
    NSArray *titles, *titles_en, *titles_cn;
}

- (void)reload
{
    if ([[MyLanguage language] isEqual:@"en"])
        titles = titles_en;
    else
        titles = titles_cn;
    
    [self.tableView reloadData];
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

    NSString *path_en = [[NSBundle mainBundle]
                         pathForResource:@"index_en"
                         ofType:@"plist"];
    
    NSDictionary *dict_en = [[NSDictionary alloc] initWithContentsOfFile:path_en];
    titles_en = [dict_en objectForKey:@"index"];
    
    NSString *path_cn = [[NSBundle mainBundle]
                         pathForResource:@"index_cn"
                         ofType:@"plist"];
    
    NSDictionary *dict_cn = [[NSDictionary alloc] initWithContentsOfFile:path_cn];
    titles_cn = [dict_cn objectForKey:@"index"];
    
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
        view.index = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        view.title_en = [titles_en[0] objectAtIndex:indexPath.row];
        view.title_cn = [titles_cn[0] objectAtIndex:indexPath.row];
        
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
        return [titles[0] count];
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
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0)
        cell.textLabel.text = @"Luke 2:3-4";
    else
        cell.textLabel.text = [titles[0] objectAtIndex:indexPath.row];

    return cell;
}

@end
