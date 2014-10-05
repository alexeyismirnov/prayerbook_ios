//
//  MyLanguage.m
//  prayerbook
//
//  Created by Alexey Smirnov on 8/4/14.
//  Copyright (c) 2014 Alexey Smirnov. All rights reserved.
//

#import "MyLanguage.h"

@implementation MyLanguage
{
    NSDictionary *currentDictionary;
}

@synthesize language = _language;

- (void)setLanguage:(NSString *)language
{
    _language= language;
    
    if ([language isEqual: DEFAULT_LANGUAGE])
        return;
    
    NSString *path = [[NSBundle mainBundle]
                      pathForResource:[NSString stringWithFormat:@"trans_%@", language]
                      ofType:@"plist"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    currentDictionary = dict;
}

+ (void)setLanguage:(NSString *)languageName
{
    MyLanguage *obj = [MyLanguage singleton];
    obj.language = languageName;
}

+ (NSString*)language
{
    MyLanguage *obj = [MyLanguage singleton];
    return obj.language;
}

- (NSString*)stringFor:(NSString*)str
{
    if (currentDictionary == nil || self.language == nil || [self.language isEqual: DEFAULT_LANGUAGE] )
        return str;
    
    NSString *result = [currentDictionary valueForKey:str];
    
    return (result == nil) ? str : result;
}

+ (NSString *)stringFor:(NSString *)str
{
    MyLanguage *obj = [MyLanguage singleton];
    return [obj stringFor:str];
}

- (NSArray*)tableViewStrings:(NSString*)code;
{
    NSString *path = [[NSBundle mainBundle]
                         pathForResource:[NSString stringWithFormat:@"index_%@", self.language]
                         ofType:@"plist"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    return [dict objectForKey:code];
}

+ (NSArray*)tableViewStrings:(NSString*)code
{
    MyLanguage *obj = [MyLanguage singleton];
    return [obj tableViewStrings:code];
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
