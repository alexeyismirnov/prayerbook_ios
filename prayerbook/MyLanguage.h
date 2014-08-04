//
//  MyLanguage.h
//  prayerbook
//
//  Created by Alexey Smirnov on 8/4/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyLanguage : NSObject
{
    NSString        *currentLanguage;
    NSDictionary    *currentDictionary;
}

+(void) setLanguage:(NSString *)languageName;
+(NSString *)stringFor:(NSString *)srcString;

+ (id)singleton;

@property (nonatomic, retain) NSString        *currentLanguage;
@property (nonatomic, retain) NSDictionary    *currentDictionary;

@end
