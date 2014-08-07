//
//  OptionsTableViewController.m
//  prayerbook
//
//  Created by Alexey Smirnov on 8/4/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

#import "OptionsTableViewController.h"
#import "MyLanguage.h"

@interface OptionsTableViewController ()
@end

@implementation OptionsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) localeChanged:(NSNotification *)paramNotification
{
    NSLog(@"Locale Changed1");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *language = [MyLanguage language];
    
    if ([language isEqual:@"en"]) {
        self.lastSelected = [NSIndexPath indexPathForRow:0 inSection:0];
        self.lang_en.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.lang_en setSelected:TRUE animated:TRUE];
        
    } else {
        self.lastSelected = [NSIndexPath indexPathForRow:1 inSection:0];
        self.lang_cn.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.lang_cn setSelected:TRUE animated:TRUE];
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int fontSize = [prefs integerForKey:@"fontSize"];
    [self.fontSizeSlider setValue:fontSize];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.lastSelected==indexPath || indexPath.section == 1) {
        return;
    }
    
    // deselect old
    UITableViewCell *old = [self.tableView cellForRowAtIndexPath:self.lastSelected];
    old.accessoryType = UITableViewCellAccessoryNone;
    [old setSelected:FALSE animated:TRUE];
    
    // select new
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [cell setSelected:TRUE animated:TRUE];
    
    // keep track of the last selected cell
    self.lastSelected = indexPath;
}

- (IBAction)cancel:(id)sender {
    [self.delegate dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

    NSIndexPath *index = [NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:index];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
        [prefs setInteger:0 forKey:@"language"];
        [MyLanguage setLanguage:@"en"];

    } else {
        [prefs setInteger:1 forKey:@"language"];
        [MyLanguage setLanguage:@"cn"];
    }
    
    int value = (int)self.fontSizeSlider.value;
    
    [prefs setInteger:value forKey:@"fontSize"];
    [prefs synchronize];

    [[NSNotificationCenter defaultCenter] postNotificationName:OPTIONS_SAVED_NOTIFICATION object:nil];

    [self.delegate dismissViewControllerAnimated:YES completion:nil];
}


@end
