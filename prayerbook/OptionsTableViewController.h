//
//  OptionsTableViewController.h
//  prayerbook
//
//  Created by Alexey Smirnov on 8/4/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionsTableViewController : UITableViewController

@property (nonatomic) UITableViewController *delegate;
@property (nonatomic) NSIndexPath *lastSelected;
@property (weak, nonatomic) IBOutlet UITableViewCell *lang_en;
@property (weak, nonatomic) IBOutlet UITableViewCell *lang_cn;

@end
