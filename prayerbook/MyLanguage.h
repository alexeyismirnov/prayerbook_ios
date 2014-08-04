//
//  MyLanguage.h
//  prayerbook
//
//  Created by Alexey Smirnov on 8/4/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DEFAULT_LANGUAGE @"en"
#define LANGUAGE_CHANGED_NOTIFICATION   @"LANGUAGE_CHANGED"

@interface MyLanguage : NSObject

+(void) setLanguage:(NSString *)languageName;
+(NSString*) language;
+(NSString *)stringFor:(NSString *)srcString;

+ (id)singleton;

@property (nonatomic, retain) NSString        *currentLanguage;
@property (nonatomic, retain) NSDictionary    *currentDictionary;

@end
