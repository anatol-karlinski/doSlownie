//
//  managerSingleton.m
//  doSłownie
//
//  Created by Anatol on 15/07/14.
//  Copyright (c) 2014 Anatol Karliński. All rights reserved.
//

#import "managerSingleton.h"

@implementation managerSingleton

@synthesize nazwaPoziomu;
@synthesize numerPoziomu;
@synthesize globalBackground;
@synthesize atlasContainer;
@synthesize guideDisplays;

+ (id)sharedManager
{
    static managerSingleton *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init{
    if (self = [super init])
    {
        nazwaPoziomu = @"Rezerwowa Nazwa Poziomu";
        numerPoziomu = 0;
        atlasContainer = [[NSMutableArray array]init];
        globalBackground = [[NSMutableArray array]init];
        guideDisplays = [[NSMutableArray array]init];
        
    }
    return self;
}

- (void)dealloc{}

@end
