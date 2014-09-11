//
//  DailyViewController.m
//  prayerbook
//
//  Created by Alexey Smirnov on 9/10/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

#import "DailyViewController.h"
#import "MyLanguage.h"

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
    
    UIColor *color = self.view.tintColor;
    
    [self.foodButton.layer setBorderColor:[color CGColor]];
    [self.foodButton.layer setBorderWidth:1.0f];
    [self.foodButton.layer setCornerRadius:10];
    [self.foodButton setTitleColor:color forState:UIControlStateNormal];


    [self reload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.infoLabel.preferredMaxLayoutWidth = self.infoLabel.frame.size.width;
    [self.view layoutIfNeeded];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [titles[0] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    UIColor* startColor = [UIColor colorWithRed:226.0/255.0 green:229.0/255.0 blue:234.0/255.0 alpha:1.0];

    
    cell.backgroundColor = startColor;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [titles[0] objectAtIndex:indexPath.row];

    return cell;
}

@end
