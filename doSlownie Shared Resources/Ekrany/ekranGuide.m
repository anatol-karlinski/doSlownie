
//
//  SKScene+ekranAbout.m
//  doSlownie-Dev-2
//
//  Created by osx on 12/11/15.
//  Copyright © 2015 osx. All rights reserved.
//

#import "ekranGuide.h"
#import "managerSingleton.h"
#import "ekranMenu.h"
#import "SKScene+SKMScene.h"
#define szerokoscSceny self.frame.size.width
#define wysokoscSceny self.frame.size.height

@interface ekranGuide ()
{
    managerSingleton *theManager; 
}

@property (strong, atomic) NSMutableArray *przyciski;
@property BOOL contentCreated;

@end

@implementation ekranGuide

int currentDisplay;

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
    
    currentDisplay = 0;
    SKTextureAtlas *atlas = [theManager.atlasContainer objectAtIndex:0];
    [self addChild:[self topBar: atlas]];
    [self addChild:[self wroc: atlas]];
    [self addChild:[self tytolPoziomu]];
    [self addChild:[self guideDisplay:theManager.guideDisplays]];
    //[self addChild:[self poprzedni:atlas]];
    //[self addChild:[self nastepny:atlas]];
    [self addChild:[self nextButton:atlas]];
    [self addChild:[self prevButton:atlas]];
}

-(void)screenInteractionStartedAtLocation:(CGPoint)location
{
    CGPoint pozycjaDotykuNaScenie = location;
    SKSpriteNode *dotknietaNode = (SKSpriteNode *)[self nodeAtPoint:pozycjaDotykuNaScenie];
    NSString *nazwaNode = dotknietaNode.name;
    
    if ([nazwaNode isEqualToString:@"nastepny"]) [self nastepnyTapped];
    else if ([nazwaNode isEqualToString:@"poprzedni"]) [self poprzedniTapped];
    else if ([nazwaNode isEqualToString:@"wroc"]) [self wrocTapped];
}

-(void)wrocTapped
{
    ekranMenu *menu = [[ekranMenu alloc] initWithSize: self.frame.size];
    theManager = NULL;
    [self.scene.view presentScene:menu transition:[SKTransition flipVerticalWithDuration:0.7]];
}

-(void)nastepnyTapped
{
    currentDisplay++;
    
    SKSpriteNode *display = (SKSpriteNode *)[self childNodeWithName:@"display"];
    SKSpriteNode *prev = (SKSpriteNode *)[self childNodeWithName:@"poprzedni"];
    SKLabelNode *tytol = (SKLabelNode *)[self childNodeWithName:@"tytol"];

    [display setTexture:[theManager.guideDisplays objectAtIndex:currentDisplay]];
    [prev setAlpha:1];
    [tytol setText:[NSString stringWithFormat:@"Jak grać - strona %i", currentDisplay+1]];
    
    if(currentDisplay == 3)
    {
        SKSpriteNode *next = (SKSpriteNode *)[self childNodeWithName:@"nastepny"];
        [next setAlpha:0];
    }
}

-(void)poprzedniTapped
{
    currentDisplay--;
    
    SKSpriteNode *display = (SKSpriteNode *)[self childNodeWithName:@"display"];
    SKSpriteNode *next = (SKSpriteNode *)[self childNodeWithName:@"nastepny"];
    SKLabelNode *tytol = (SKLabelNode *)[self childNodeWithName:@"tytol"];

    [display setTexture:[theManager.guideDisplays objectAtIndex:currentDisplay]];
    [next setAlpha:1];
    [tytol setText:[NSString stringWithFormat:@"Jak grać - strona %i", currentDisplay+1]];
    
    if(currentDisplay == 0)
    {
        SKSpriteNode *prev = (SKSpriteNode *)[self childNodeWithName:@"poprzedni"];
        [prev setAlpha:0];
    }
}

#if !TARGET_OS_IPHONE
- (void)keyDown:(NSEvent *)event {
    NSString *characters = [event characters];
    if([characters isEqualToString:@"\x1b"])[self wrocTapped];
    
}
#endif

-(SKSpriteNode *)topBar:(SKTextureAtlas *)atlas
{
    SKSpriteNode* node = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"global_topBar"]];
    [node setAnchorPoint:CGPointMake(1.0, 1.0)];
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
    [node setText:@"Jak grać - strona 1"];
    [node setName:@"tytol"];
    [node setFontSize:22.0];
    [node setZPosition:4];
    [node setPosition:CGPointMake(self.frame.size.width/2, self.frame.size.height-44.0)];
    return node;
}

-(SKSpriteNode *)guideDisplay:(NSMutableArray *)atlas
{
    SKSpriteNode* node = [SKSpriteNode spriteNodeWithTexture:[atlas objectAtIndex:0]];
    [node setAnchorPoint:CGPointMake(0.0, 0.0)];
    [node setPosition:CGPointMake(0.0, 0.0)];
    [node setName:@"display"];
    [node setZPosition:0];
    return node;
}

-(SKSpriteNode *)nextButton:(SKTextureAtlas *)atlasTextur
{
    SKSpriteNode *button = [SKSpriteNode spriteNodeWithTexture:[atlasTextur textureNamed:@"flatButton"]];
    [button setPosition:CGPointMake(self.size.width-105.0, self.size.height-110.0)];
    [button setAnchorPoint:CGPointMake(0.5, 0.5)];
    [button setZPosition:0];
    [button setYScale:-1.0];
    
    SKSpriteNode *arrow = [SKSpriteNode spriteNodeWithTexture:[atlasTextur textureNamed:@"global_backButton"]];
    [button addChild:arrow];
    [arrow setXScale:arrow.xScale*(-1.25)];
    [arrow setPosition:CGPointMake(arrow.position.x+56.0, arrow.position.y-8.0)];
    [arrow setColor:[SKColor whiteColor]];
    [arrow setColorBlendFactor:1.0];
    [arrow setName:@"nastepny"];
    
    SKLabelNode *tekst = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Medium"];
    [tekst setText:@"Dalej"];
    [tekst setName:@"nastepny"];
    [tekst setFontSize:28.0];
    [tekst setYScale:-1.0];
    [tekst setFontColor:[SKColor colorWithRed:0.8978 green:0.9113 blue:0.9227 alpha:1.0]];
    [tekst setPosition:CGPointMake(tekst.position.x-10.0, tekst.position.y+3.0)];
    
    [button addChild:tekst];
    [button setName:@"nastepny"];
    
    return button;
}

-(SKSpriteNode *)prevButton:(SKTextureAtlas *)atlasTextur
{
    SKSpriteNode *button = [SKSpriteNode spriteNodeWithTexture:[atlasTextur textureNamed:@"flatButton"]];
    [button setPosition:CGPointMake(self.size.width-310.0, self.size.height-110.0)];
    [button setAnchorPoint:CGPointMake(0.5, 0.5)];
    [button setZPosition:0];
    [button setYScale:-1.0];
    
    SKSpriteNode *arrow = [SKSpriteNode spriteNodeWithTexture:[atlasTextur textureNamed:@"global_backButton"]];
    [button addChild:arrow];
    [arrow setXScale:arrow.xScale*(1.25)];
    [arrow setPosition:CGPointMake(arrow.position.x-46.0, arrow.position.y-7.0)];
    [arrow setColor:[SKColor whiteColor]];
    [arrow setColorBlendFactor:1.0];
    [arrow setName:@"poprzedni"];
    
    SKLabelNode *tekst = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Medium"];
    [tekst setText:@"Wróć"];
    [tekst setFontSize:28.0];
    [tekst setName:@"poprzedni"];
    [tekst setFontColor:[SKColor colorWithRed:0.8978 green:0.9113 blue:0.9227 alpha:1.0]];
    [tekst setPosition:CGPointMake(tekst.position.x+14.0, tekst.position.y+3.0)];
    [tekst setYScale:-1.0];
    
    [button addChild:tekst];
    [button setName:@"poprzedni"];
    [button setAlpha:0.0];
    
    return button;
}

@end
