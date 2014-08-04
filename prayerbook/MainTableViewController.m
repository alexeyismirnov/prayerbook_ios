//
//  MainTableViewController.m
//  prayerbook
//
//  Created by Alexey Smirnov on 8/4/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

#import "MainTableViewController.h"
#import "MyLanguage.h"
#import "OptionsTableViewController.h"

@interface MainTableViewController ()
-(void)updateLanguage;
@end

@implementation MainTableViewController

NSArray *titles;

- (void)updateLanguage
{
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:[NSString  stringWithFormat:@"index_%@",  [MyLanguage language] ]
                      ofType:@"plist"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    titles = [dict objectForKey:@"index"];

    [self.tableView reloadData];
}

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
    NSLog(@"Locale Changed2");
    
    [self updateLanguage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateLanguage];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(localeChanged:)
     name:LANGUAGE_CHANGED_NOTIFICATION
     object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [titles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [titles[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [titles[indexPath.section] objectAtIndex:indexPath.row];
    
    return cell;
}

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
     if ([segue.identifier isEqualToString:@"Options"])
     {
         UINavigationController *navigationController = segue.destinationViewController;
         OptionsTableViewController *options = [navigationController viewControllers][0];
         options.delegate = self;
     }

 }


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


@end
