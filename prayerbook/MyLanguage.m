//
//  MyLanguage.m
//  prayerbook
//
//  Created by Alexey Smirnov on 8/4/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

#import "MyLanguage.h"

@implementation MyLanguage

+(void) setLanguage:(NSString *)languageName;
{
    MyLanguage *gsObject = [MyLanguage singleton];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"index_%@", languageName] ofType:@"plist"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    
    gsObject.currentDictionary = dict;
    gsObject.currentLanguage = languageName;
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:LANGUAGE_CHANGED_NOTIFICATION object:nil];
    
}

+(NSString *)stringFor:(NSString *)srcString;
{
    MyLanguage *gsObject = [MyLanguage singleton];

    if (gsObject.currentDictionary == nil || gsObject.currentLanguage == nil )
        return srcString;
    
    // use current dictionary for translation.
    NSString *results = [gsObject.currentDictionary valueForKey:srcString];
    
    if (results == nil)
        return srcString;
    
    return results;
}

+ (id)singleton;
{
    static MyLanguage *shared = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}


@end
