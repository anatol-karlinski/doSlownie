//
//  ekranMenu.m
//  ProjektW
//
//  Created by Anatol on 27/05/14.
//  Copyright (c) 2014 Anatol. All rights reserved.
//

#import "ekranMenu.h"
#import "ekranAbout.h"
#import "ekranGuide.h"
#import "ekranWyboruPoziomu.h"
#import "managerSingleton.h"
#import "SKScene+SKMScene.h"

@interface ekranMenu ()
{
    managerSingleton *theManager;
}

@property (strong, atomic) NSMutableArray *przyciski;
@property (strong, atomic) NSString *ostatniPrzycisk;
@property BOOL contentCreated;
@property float NODE_SCALE_FACTOR;

@end

@implementation ekranMenu

@synthesize ostatniPrzycisk;
@synthesize przyciski;
@synthesize NODE_SCALE_FACTOR;

#pragma mark Budowa sceny

-(void)didMoveToView: (SKView *) view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

-(void)createSceneContents
{
    self.backgroundColor = [SKColor whiteColor];
    self.scaleMode = SKSceneScaleModeFill;
    #if TARGET_OS_IPHONE
    self.view.multipleTouchEnabled = NO;
    NODE_SCALE_FACTOR = 1.0;
    #else
    NODE_SCALE_FACTOR = 1.0;
    #endif

    przyciski = [[NSMutableArray alloc]init];
    theManager = [managerSingleton sharedManager];
    
    SKTextureAtlas *atlas = [theManager.atlasContainer objectAtIndex:0];
    [self addChild:[self background: [theManager.globalBackground objectAtIndex:0]]];
    [self addChild:[self logo: atlas]];
    [self addChild:[self barTop: atlas]];
    [self addChild:[self graj: atlas]];
    [self addChild:[self jakGrac: atlas]];
    [self addChild:[self about: atlas]];
    //[self addChild:[self reset]];
    //[self animacjaWejscia];
    
}

#pragma mark Interakcja z użytkownikiem

-(void)screenInteractionStartedAtLocation:(CGPoint)location
{
    CGPoint pozycjaDotykuNaScenie = location;
    SKSpriteNode *dotknietaNode = (SKSpriteNode *)[self nodeAtPoint:pozycjaDotykuNaScenie];
    NSString *nazwaDotknietegoNode = dotknietaNode.name;
    
    if ([nazwaDotknietegoNode isEqualToString:@"wejscie"]) [self animacjaWejscia];
    
    else if ([nazwaDotknietegoNode isEqualToString:@"wyjscie"]) [self grajTapped];
    
    else if ([nazwaDotknietegoNode isEqualToString:@"reset"])
    {
        NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
        [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
    }
    
    if ((nazwaDotknietegoNode != nil) && [przyciski containsObject:dotknietaNode])
    {
        ostatniPrzycisk = nazwaDotknietegoNode;
        SKAction *expand = [SKAction scaleTo:(1.07*NODE_SCALE_FACTOR) duration:0.07];
        [dotknietaNode runAction:expand];
    }
}

-(void)screenInteractionDraggedToLocation:(CGPoint)location
{
    CGPoint pozycjaDotykuNaScenie = location;
    SKSpriteNode *dotknietaNode = (SKSpriteNode *)[self nodeAtPoint:pozycjaDotykuNaScenie];
    NSString *nazwaDotknietegoNode = dotknietaNode.name;
    
    if (nazwaDotknietegoNode == nil || nazwaDotknietegoNode != ostatniPrzycisk)
    {
        for (SKSpriteNode *przyciskzArray in przyciski)
        {
            SKAction *retract = [SKAction scaleTo:(1.0*NODE_SCALE_FACTOR) duration:0.07];
            [przyciskzArray runAction:retract];
            ostatniPrzycisk = nil;
        }
        if (nazwaDotknietegoNode != ostatniPrzycisk && [przyciski containsObject:dotknietaNode])
        {
            ostatniPrzycisk = nazwaDotknietegoNode;
            SKAction *expand = [SKAction scaleTo:(1.07*NODE_SCALE_FACTOR) duration:0.07];
            [dotknietaNode runAction:expand];
        }
    }
}

-(void)screenInteractionEndedAtLocation:(CGPoint)location
{
    CGPoint pozycjaDotykuNaScenie = location;
    SKSpriteNode *dotknietaNode = (SKSpriteNode *)[self nodeAtPoint:pozycjaDotykuNaScenie];
    NSString *nazwaDotknietegoNode = dotknietaNode.name;
    
    if ([nazwaDotknietegoNode isEqualToString:@"graj"]) [self grajTapped];
    else if ([nazwaDotknietegoNode isEqualToString:@"about"]) [self aboutTapped];
    else if ([nazwaDotknietegoNode isEqualToString:@"guide"]) [self guideTapped];
    else if (![nazwaDotknietegoNode isEqualToString:@"wyjscie"] && ![nazwaDotknietegoNode isEqualToString:@"wejscie"])
    {
        for (SKSpriteNode *przyciskzArray in przyciski)
        {
            SKAction *retract = [SKAction scaleTo:(1.0*NODE_SCALE_FACTOR) duration:0.1];
            [przyciskzArray runAction:retract];
        }
    }
}

#pragma mark Animacje

-(void)animacjaWejscia
{
    SKAction *pojaw = [SKAction fadeAlphaTo:1.0 duration:0.10];
    SKAction *powieksz = [SKAction scaleTo:1.0 duration:0.18];
    
    SKSpriteNode *logo = (SKSpriteNode *)[self childNodeWithName:@"logo"];
    SKAction *przemiescLogo = [SKAction moveByX:0.0 y:-20.0 duration:0.18];
    [logo runAction:przemiescLogo];
    [logo runAction:pojaw];
    
    SKLabelNode *copyright = (SKLabelNode *)[self childNodeWithName:@"copyrights"];
    SKAction *przemiescCopy = [SKAction moveByX:0.0 y:20.0 duration:0.18];
    [copyright runAction:przemiescCopy];
    [copyright runAction:pojaw];
    
    SKLabelNode *botBar = (SKLabelNode *)[self childNodeWithName:@"botBar"];
    [botBar runAction:powieksz];
    
    SKLabelNode *topBar = (SKLabelNode *)[self childNodeWithName:@"topBar"];
    [topBar runAction:powieksz];
    
    int i=0;
    for (SKSpriteNode *guzik in przyciski)
    {
        SKAction *czekaj = [SKAction waitForDuration:(0.08*i)];
        SKAction *znmiejsz = [SKAction scaleTo:1.0 duration:0.2];
        SKAction *animacjaZmniejszenia = [SKAction sequence:@[czekaj, znmiejsz]];
        [guzik runAction:animacjaZmniejszenia];
        i++;
    }
}

-(void)grajTapped
{
    [self zestawTapped:@"Main"];
}

-(void)zestawTapped:(NSString *)nazwaLable
{
    ekranWyboruPoziomu *poziomy = [[ekranWyboruPoziomu alloc] initWithSize: self.frame.size];
    theManager.nazwaZestawu = nazwaLable;
    theManager = NULL;
    [self.scene.view presentScene:poziomy transition:[SKTransition flipVerticalWithDuration:0.7]];
}

-(void)aboutTapped
{
    ekranAbout *about = [[ekranAbout alloc] initWithSize: self.frame.size];
    theManager = NULL;
    [self.scene.view presentScene: about transition:[SKTransition flipVerticalWithDuration:0.7]];
}

-(void)guideTapped
{
    ekranGuide *guide = [[ekranGuide alloc] initWithSize: self.frame.size];
    theManager = NULL;
    [self.scene.view presentScene: guide transition:[SKTransition flipVerticalWithDuration:0.7]];
}

#pragma mark Elementy interfejsu

-(SKSpriteNode *)background:(SKSpriteNode *)node
{
    SKSpriteNode* bg = [SKSpriteNode spriteNodeWithTexture:(SKTexture *)[node texture]];
    [bg setPosition:CGPointZero];
    [bg setAnchorPoint:CGPointMake(0.0, 0.0)];
    [bg setZPosition:-1];
    return bg;
}

-(SKLabelNode *)reset
{
    SKLabelNode *reset = [SKLabelNode labelNodeWithFontNamed:@"Helvetica Neue Thin"];
    [reset setText:@"RESET"];
    [reset setFontColor:[SKColor grayColor]];
    [reset setFontSize:40.0];
    [reset setPosition:CGPointMake(70.0, 20.0)];
    [reset setName:@"reset"];
    [reset setAlpha:1.0];
    [reset setZPosition:1];
    return reset;
}

-(SKSpriteNode *)logo:(SKTextureAtlas *)atlas
{
    SKSpriteNode* node = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"main_logo"]];
    [node setName:@"logo"];
    [node setPosition:CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + 270.0 + 20.0)];
    [node setAlpha:1.0];
    [node setScale:1.0*NODE_SCALE_FACTOR];
    [node setZPosition:1];
    return node;
}

-(SKSpriteNode *)barTop:(SKTextureAtlas *)atlas
{
    SKSpriteNode* node = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"global_grayBar"]];
    [node setScale:1.0*NODE_SCALE_FACTOR];
    [node setPosition:CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + 210.0)];
    [node setName:@"topBar"];
    [node setZPosition:1];
    return node;
}

-(SKSpriteNode *)botBar:(SKTextureAtlas *)atlas
{
    SKSpriteNode* node = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"global_grayBar"]];
    [node setPosition:CGPointMake(self.frame.size.width/2, self.frame.size.height/2 - 210.0)];
    [node setName:@"botBar"];
    [node setZPosition:1];
    [node setScale:1.0*NODE_SCALE_FACTOR];
    return node;
}

-(SKSpriteNode *)graj:(SKTextureAtlas *)atlas
{
    
    SKSpriteNode* node = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"menu_graj"]];
    [node setPosition:CGPointMake(self.frame.size.width/2, self.frame.size.height/2 + 90.0)];
    [node setName:@"graj"];
    [node setZPosition:1];
    [node setScale:1.0*NODE_SCALE_FACTOR];
    [przyciski addObject:node];
    return node;
}

-(SKSpriteNode *)jakGrac:(SKTextureAtlas *)atlas
{
    SKSpriteNode* node = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"menu_jak"]];
    [node setPosition:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
    [node setName:@"guide"];
    [node setZPosition:1];
    [przyciski addObject:node];
    [node setScale:1.0*NODE_SCALE_FACTOR];
    return node;
}

-(SKSpriteNode *)about:(SKTextureAtlas *)atlas
{
    SKSpriteNode* node = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"menu_about"]];
    [node setPosition:CGPointMake(self.frame.size.width/2, self.frame.size.height/2-90)];
    [node setName:@"about"];
    [node setZPosition:1];
    [przyciski addObject:node];
    [node setScale:1.0*NODE_SCALE_FACTOR];
    return node;
}
@end

