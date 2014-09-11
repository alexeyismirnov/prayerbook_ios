//
//  DailyViewController.h
//  prayerbook
//
//  Created by Alexey Smirnov on 9/10/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DailyViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *foodButton;
@property (weak, nonatomic) IBOutlet UILabel *foodLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
