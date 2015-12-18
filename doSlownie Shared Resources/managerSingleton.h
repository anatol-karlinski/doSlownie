//
//  managerSingleton.h
//  doSłownie
//
//  Created by Anatol on 15/07/14.
//  Copyright (c) 2014 Anatol Karliński. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface managerSingleton : NSObject
{
    NSString *nazwaPoziomu;
    NSInteger numerPoziomu;
    NSMutableArray *atlasContainer;
    NSMutableArray *globalBackground;
    NSMutableArray *guideDisplays;
}

@property (nonatomic, retain) NSString *nazwaZestawu;
@property (nonatomic, retain) NSString *nazwaPoziomu;
@property NSInteger numerPoziomu;
@property (nonatomic, retain) NSMutableArray *atlasContainer;
@property (nonatomic, retain) NSMutableArray *globalBackground;
@property (nonatomic, retain) NSMutableArray *guideDisplays;

+(id)sharedManager;

@end
