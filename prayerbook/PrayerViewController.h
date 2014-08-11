//
//  PrayerViewController.h
//  prayerbook
//
//  Created by Alexey Smirnov on 8/5/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrayerViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) NSIndexPath *index;

@property (nonatomic) NSString *title_en;
@property (nonatomic) NSString *title_cn;

@end
