
//
//  SKScene+ekranAbout.m
//  doSlownie-Dev-2
//
//  Created by osx on 12/11/15.
//  Copyright © 2015 osx. All rights reserved.
//

#import "ekranAbout.h"
#import "managerSingleton.h"
#import "ekranMenu.h"
#import "SKScene+SKMScene.h"
#define szerokoscSceny self.frame.size.width
#define wysokoscSceny self.frame.size.height

@interface ekranAbout ()
{
    managerSingleton *theManager; 
}

@property (strong, atomic) NSMutableArray *przyciski;
@property BOOL contentCreated;

@end

@implementation ekranAbout

@synthesize przyciski;

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
    #endif
    
    przyciski = [[NSMutableArray alloc]init];
    theManager = [managerSingleton sharedManager];
    
    SKTextureAtlas *atlas = [theManager.atlasContainer objectAtIndex:0];
    [self addChild:[self background: [theManager.globalBackground objectAtIndex:0]]];
    [self addChild:[self topBar: atlas]];
    [self addChild:[self wroc: atlas]];
    [self addChild:[self tytolPoziomu]];
    [self addChild:[self about]];
}

-(void)screenInteractionStartedAtLocation:(CGPoint)location
{
    CGPoint pozycjaDotykuNaScenie = location;
    SKSpriteNode *dotknietaNode = (SKSpriteNode *)[self nodeAtPoint:pozycjaDotykuNaScenie];
    NSString *nazwaNode = dotknietaNode.name;
    
    if ([nazwaNode isEqualToString:@"wroc"]) [self wrocTapped];
}

-(void)wrocTapped
{
    ekranMenu *menu = [[ekranMenu alloc] initWithSize: self.frame.size];
    theManager = NULL;
    [self.scene.view presentScene:menu transition:[SKTransition flipVerticalWithDuration:0.7]];
}

#if !TARGET_OS_IPHONE
- (void)keyDown:(NSEvent *)event {
    NSString *characters = [event characters];
    if([characters isEqualToString:@"\x1b"])[self wrocTapped];
    
}
#endif

-(SKSpriteNode *)background:(SKSpriteNode *)node
{
    SKSpriteNode* bg = [SKSpriteNode spriteNodeWithTexture:(SKTexture *)[node texture]];
    [bg setPosition:CGPointZero];
    [bg setAnchorPoint:CGPointMake(0.0, 0.0)];
    [bg setZPosition:-1];
    return bg;
}

-(SKSpriteNode *)about
{
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:@"about"];
    [node setPosition:CGPointZero];
    [node setAnchorPoint:CGPointMake(0.0, 0.0)];
    [node setZPosition:0];
    return node;
}

-(SKSpriteNode *)topBar:(SKTextureAtlas *)atlas
{
    SKSpriteNode* node = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"global_topBar"]];
    CGPoint anchor = CGPointMake(1.0, 1.0);
    [node setAnchorPoint:anchor];
    [node setPosition:CGPointMake(self.size.width, self.size.height-4.0)];
    [node setZPosition:1];
    return node;
}

-(SKSpriteNode *)wroc:(SKTextureAtlas *)atlas
{
    SKSpriteNode* node = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"global_backButton"]];
    [node setAnchorPoint:CGPointMake(0.0, 1.0)];
    [node setPosition:CGPointMake(16.0, self.frame.size.height-16.0)];
    [node setName:@"wroc"];
    [node setZPosition:2];
    return node;
}

-(SKLabelNode *)tytolPoziomu
{
    SKLabelNode *node = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue-Bold"];
    [node setFontColor:[SKColor colorWithRed:0.8078 green:0.8313 blue:0.8627 alpha:1.0]];
    [node setText:@"O doSłownie"];
    [node setFontSize:22.0];
    [node setZPosition:4];
    [node setPosition:CGPointMake(self.frame.size.width/2, self.frame.size.height-44.0)];
    return node;
}

@end
