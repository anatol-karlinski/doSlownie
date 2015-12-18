//
//  ekranWyboru.m
//  ProjektW
//
//  Created by Anatol on 24/05/14.
//  Copyright (c) 2014 Anatol. All rights reserved.
//

#import "ekranWyboruPoziomu.h"
#import "ekranGry.h"
#import "managerSingleton.h"
#import "ekranMenu.h"
#import "SKScene+SKMScene.h"

#define szerokoscSceny self.frame.size.width
#define wysokoscSceny self.frame.size.height
#define POZIOMOW_NA_STRONE 25

@interface ekranWyboruPoziomu ()
{
    managerSingleton *theManager;
}

@property BOOL contentCreated;
@property (strong, atomic) NSMutableArray *listaPoziomow;
@property (strong, atomic) NSUserDefaults *defaults;
@property int strona;
@end

@implementation ekranWyboruPoziomu

#pragma mark Budowa sceny

@synthesize defaults;
@synthesize strona;
@synthesize listaPoziomow;

-(void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
    }
}

-(void)createSceneContents
{
    self.scaleMode = SKSceneScaleModeFill;

#if TARGET_OS_IPHONE
    self.view.multipleTouchEnabled = NO;
#endif
    
    defaults = [NSUserDefaults standardUserDefaults];
    theManager = [managerSingleton sharedManager];
    NSString* sciezkaDB = [[NSBundle mainBundle] pathForResource:@"poziomy_db" ofType:@"plist"];
    NSDictionary* db = [NSDictionary dictionaryWithContentsOfFile:sciezkaDB];
    NSArray *poziomy = [db valueForKeyPath:@"poziomy"];
    SKTextureAtlas *atlas = [theManager.atlasContainer objectAtIndex:0];
    int row = 0, column = 0, page = 0, iloscGwiazd = 0;
    strona = 0;
    listaPoziomow = [[NSMutableArray array]init];
    
    for (int i=0; i<[poziomy count]; i++)
        [self addChild:[self poziom:[poziomy objectAtIndex:i] :i :atlas :&iloscGwiazd :&row :&column :&page]];
    [self addChild:[self dolnyPanel:atlas:&iloscGwiazd]];
    [self addChild:[self topBar:atlas]];
    [self addChild:[self wroc:atlas]];
    [self addChild:[self tytolPoziomu]];
    [self addChild:[self nextButton:atlas]];
    [self addChild:[self prevButton:atlas]];
    [self addChild:[self background: [theManager.globalBackground objectAtIndex:0]]];
    
    [defaults synchronize];
}

#pragma mark Interakcja z użytkownikiem

-(void)screenInteractionStartedAtLocation:(CGPoint)location
{
    CGPoint pozycjaDotykuNaScenie = location;
    SKSpriteNode *dotknietaNode = (SKSpriteNode *)[self nodeAtPoint:pozycjaDotykuNaScenie];
    NSArray *name = [dotknietaNode.name componentsSeparatedByString:@"_"];
    if ([[name objectAtIndex:0] isEqualToString:@"Poziom"])[self poziomTapped:[name objectAtIndex:2]:[name objectAtIndex:1]];
    else if ([[name objectAtIndex:0] isEqualToString:@"wroc"])[self wrocTapped];
    else if ([[name objectAtIndex:0] isEqualToString:@"nextButton"])[self toNextPage];
    else if ([[name objectAtIndex:0] isEqualToString:@"prevButton"])[self toPrevPage];

}

-(void)poziomTapped :(NSString *)nazwaNode :(NSString *)numerPoziomu;
{
    theManager.numerPoziomu = [numerPoziomu integerValue];
    theManager.nazwaPoziomu = nazwaNode;
    ekranGry *poziom = [[ekranGry alloc] initWithSize: self.frame.size];
    SKTransition *przejscie = [SKTransition pushWithDirection:SKTransitionDirectionLeft duration:0.6];
    [self.scene.view presentScene:poziom transition:przejscie];
}

-(void)wrocTapped
{
    ekranMenu *menu = [[ekranMenu alloc] initWithSize: self.frame.size];
    theManager = NULL;
    [self.scene.view presentScene:menu transition:[SKTransition flipVerticalWithDuration:0.7]];
}

-(void)toNextPage
{
    double iloscPoziomow = [listaPoziomow count];
    for(int i=0;i<iloscPoziomow;i++)
    {
        SKAction* animacjaPrzejscia = [SKAction moveBy:CGVectorMake(-szerokoscSceny, 0.0) duration:0.45];
        [[listaPoziomow objectAtIndex:i] runAction:animacjaPrzejscia];
    }
    strona++;
    if (strona+1 == ceil(iloscPoziomow/POZIOMOW_NA_STRONE))
    {
        SKSpriteNode* nextButton = (SKSpriteNode *)[self childNodeWithName:@"nextButton"];
        [nextButton setHidden:YES];
    }
    SKSpriteNode* prevButton = (SKSpriteNode *)[self childNodeWithName:@"prevButton"];
    [prevButton setHidden:NO];
    
}

-(void)toPrevPage
{
    for(int i=0;i<[listaPoziomow count];i++)
    {
        SKAction* animacjaPrzejscia = [SKAction moveBy:CGVectorMake(szerokoscSceny, 0.0) duration:0.45];
        [[listaPoziomow objectAtIndex:i] runAction:animacjaPrzejscia];
    }
    strona--;
    if (strona+1 == 1)
    {
        SKSpriteNode* prevButton = (SKSpriteNode *)[self childNodeWithName:@"prevButton"];
        [prevButton setHidden:YES];
    }
    SKSpriteNode* nextButton = (SKSpriteNode *)[self childNodeWithName:@"nextButton"];
    [nextButton setHidden:NO];
}

#if !TARGET_OS_IPHONE
- (void)keyDown:(NSEvent *)event {
    NSString *characters = [event characters];
    if([characters isEqualToString:@"\x1b"])[self wrocTapped];

}
#endif

#pragma mark Elementy interfejsu

-(SKSpriteNode *)background:(SKSpriteNode *)node
{
    SKSpriteNode* bg = [SKSpriteNode spriteNodeWithTexture:(SKTexture *)[node texture]];
    [bg setPosition:CGPointZero];
    [bg setAnchorPoint:CGPointMake(0.0, 0.0)];
    [bg setZPosition:-1];
    return bg;
}

-(SKSpriteNode *)nextButton:(SKTextureAtlas *)atlasTextur
{
    SKSpriteNode *button = [SKSpriteNode spriteNodeWithTexture:[atlasTextur textureNamed:@"flatButton"]];
    [button setPosition:CGPointMake(szerokoscSceny/2+270.0, 46.0)];
    [button setAnchorPoint:CGPointMake(0.5, 0.5)];
    [button setZPosition:1];
    [button setScale:1.0];
    
    SKSpriteNode *arrow = [SKSpriteNode spriteNodeWithTexture:[atlasTextur textureNamed:@"global_backButton"]];
    [button addChild:arrow];
    [arrow setXScale:arrow.xScale*(-1.25)];
    [arrow setPosition:CGPointMake(arrow.position.x+56.0, arrow.position.y-8.0)];
    [arrow setColor:[SKColor whiteColor]];
    [arrow setColorBlendFactor:1.0];
    [arrow setName:@"nextButton"];
    SKLabelNode *tekst = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Medium"];
    [tekst setText:@"Dalej"];
    [tekst setFontSize:28.0];
    [tekst setFontColor:[SKColor colorWithRed:0.8978 green:0.9113 blue:0.9227 alpha:1.0]];
    [tekst setPosition:CGPointMake(tekst.position.x-10.0, tekst.position.y-17.0)];
    [tekst setName:@"nextButton"];

    [button addChild:tekst];
    [button setName:@"nextButton"];
    
    return button;
}

-(SKSpriteNode *)prevButton:(SKTextureAtlas *)atlasTextur
{
    SKSpriteNode *button = [SKSpriteNode spriteNodeWithTexture:[atlasTextur textureNamed:@"flatButton"]];
    [button setPosition:CGPointMake(szerokoscSceny/2-270.0, 46.0)];
    [button setAnchorPoint:CGPointMake(0.5, 0.5)];
    [button setZPosition:1];
    [button setScale:1.0];
    
    SKSpriteNode *arrow = [SKSpriteNode spriteNodeWithTexture:[atlasTextur textureNamed:@"global_backButton"]];
    [button addChild:arrow];
    [arrow setXScale:arrow.xScale*(1.25)];
    [arrow setPosition:CGPointMake(arrow.position.x-56.0, arrow.position.y-7.0)];
    [arrow setColor:[SKColor whiteColor]];
    [arrow setColorBlendFactor:1.0];
    [arrow setName:@"prevButton"];
    
    SKLabelNode *tekst = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Medium"];
    [tekst setText:@"Wróć"];
    [tekst setFontSize:28.0];
    [tekst setFontColor:[SKColor colorWithRed:0.8978 green:0.9113 blue:0.9227 alpha:1.0]];
    [tekst setPosition:CGPointMake(tekst.position.x+10.0, tekst.position.y-17.0)];
    [tekst setName:@"prevButton"];
    
    [button addChild:tekst];
    [button setName:@"prevButton"];
    [button setHidden:YES];
    
    return button;
}

-(SKSpriteNode *)dolnyPanel:(SKTextureAtlas *)atlasTextur :(int*)iloscGwiazdInt
{
    SKSpriteNode *panel = [SKSpriteNode spriteNodeWithTexture:[atlasTextur textureNamed:@"poziomy_dolnyPanel"]];
    [panel setPosition:CGPointMake(szerokoscSceny/2, 46.0)];
    [panel setAnchorPoint:CGPointMake(0.5, 0.5)];
    [panel setZPosition:1];
    [panel setScale:1.0];
    
    SKSpriteNode *gwiazda = [SKSpriteNode spriteNodeWithTexture:[atlasTextur textureNamed:@"zestawy_starIn"]];
    [panel addChild:gwiazda];
    [gwiazda setPosition:CGPointMake(-30.0, -8.0)];
    [gwiazda setZPosition:2];
    
    SKLabelNode *iloscGwiazd = [SKLabelNode labelNodeWithFontNamed:@"STHeitiTC-Medium"];
    [iloscGwiazd setFontColor:[SKColor whiteColor]];
    [iloscGwiazd setFontSize:27.0];
    [iloscGwiazd setText:[NSString stringWithFormat:@"x %d", *iloscGwiazdInt]];
    [iloscGwiazd setPosition:CGPointMake(-6.0, -20.0)];
    [iloscGwiazd setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeLeft];
    [panel addChild:iloscGwiazd];
    [iloscGwiazd setZPosition:2];
    
    return panel;
}

-(SKSpriteNode *)topBar:(SKTextureAtlas *)atlasTextur
{
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:[atlasTextur textureNamed:@"global_topBar"]];
    [node setAnchorPoint:CGPointMake(1.0, 1.0)];
    [node setPosition:CGPointMake(self.size.width, self.size.height-4.0)];
    [node setZPosition:1];
    [node setScale:1.0];
    return node;
}

-(SKSpriteNode *)wroc:(SKTextureAtlas *)atlasTextur
{
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithTexture:[atlasTextur textureNamed:@"global_backButton"]];
    [node setAnchorPoint:CGPointMake(0.0, 1.0)];
    [node setPosition:CGPointMake(16.0, self.frame.size.height-16.0)];
    [node setName:@"wroc"];
    [node setScale:1.0];
    [node setZPosition:2];
    return node;
}

-(SKLabelNode *)tytolPoziomu
{
    SKLabelNode *node = [SKLabelNode labelNodeWithFontNamed:@"Avenir-Medium"];
    [node setFontColor:[SKColor colorWithRed:0.8078 green:0.8313 blue:0.8627 alpha:1.0]];
    [node setText:@"Wybierz poziom"];
    [node setFontSize:26.0];
    [node setZPosition:4];
    [node setPosition:CGPointMake(self.frame.size.width/2, self.frame.size.height-46.0)];
    return node;
}

-(SKSpriteNode *)poziom :(NSString *)nazwaPoziomu :(int)i :(SKTextureAtlas *)atlasTextur :(int *)iloscGwiazd :(int*)row :(int *)column :(int *)page
{
    SKSpriteNode *tlo = [SKSpriteNode spriteNodeWithTexture:[atlasTextur textureNamed:@"poziomy_buttonBackground"]];
    SKLabelNode *numer = [SKLabelNode labelNodeWithFontNamed:@"STHeitiTC-Medium"];
    NSString *punkty = [defaults objectForKey:[nazwaPoziomu stringByAppendingString:@"_punkty"]];

    if (*column == 5)
    {
        (*row)++;
        *column = 0;
    }
    if (*row == 5)
    {
        *row = 0;
        *column = 0;
        (*page)++;
    }
    NSString *name = [NSString stringWithFormat:@"Poziom_%d_%@",i+1, nazwaPoziomu];
    //[tlo setAccessibilityLabel:nazwaPoziomu];
    [tlo setName:name];
    [tlo setPosition:CGPointMake((szerokoscSceny*(0.5)-304.0+(152.0*(*column))+(szerokoscSceny*(*page))), wysokoscSceny - 160.0 - (170.0*(*row)))];
    [tlo setZPosition:1];
    
    [numer setText:[NSString stringWithFormat:@"%i", i+1]];
    [numer setName:name];
    [numer setFontSize:46.0];
    [numer setScale:1.0];
    [numer setFontColor:[SKColor whiteColor]];
    [numer setPosition:CGPointMake(0.0, 5.0)];
    [numer setZPosition:2];
    [tlo addChild:numer];

    switch ([punkty integerValue])
    {
        case 0:
        {
            SKSpriteNode *gwiazda = [SKSpriteNode spriteNodeWithTexture:[atlasTextur textureNamed:@"zestawy_starOut"]];
            [gwiazda setName:name];
            [gwiazda setScale:0.8];
            [gwiazda setZPosition:3];
            [tlo addChild:gwiazda];
            [gwiazda setPosition:CGPointMake(0.0, -28.0)];
        }
            break;
        case 1:
        {
            SKSpriteNode *gwiazda = [SKSpriteNode spriteNodeWithTexture:[atlasTextur textureNamed:@"zestawy_starIn"]];
            [gwiazda setName:name];
            [gwiazda setScale:0.8];
            [gwiazda setZPosition:3];
            [tlo addChild:gwiazda];
            [gwiazda setPosition:CGPointMake(0.0, -28.0)];
            (*iloscGwiazd)++;
        }
            break;
        case 2:
        {
            for (int i=0; i<2; i++)
            {
                SKSpriteNode *gwiazda = [SKSpriteNode spriteNodeWithTexture:[atlasTextur textureNamed:@"zestawy_starIn"]];
                [gwiazda setName:name];
                [gwiazda setScale:0.8];
                [gwiazda setZPosition:3];
                [tlo addChild:gwiazda];
                [gwiazda setPosition:CGPointMake(-16.0+(32.0*i), -28.0)];
                (*iloscGwiazd)++;
            }
        }
            break;
        case 3:
        {
            for (int i=0; i<3; i++)
            {
                SKSpriteNode *gwiazda = [SKSpriteNode spriteNodeWithTexture:[atlasTextur textureNamed:@"zestawy_starIn"]];
                [gwiazda setName:name];
                [gwiazda setScale:0.8];
                [gwiazda setZPosition:3];
                [tlo addChild:gwiazda];
                [gwiazda setPosition:CGPointMake(-32.0+(32.0*i), -28.0)];
                (*iloscGwiazd)++;
            }
        }
            break;
            
        default:
            break;
    }
    (*column)++;
    [tlo setScale:1.0];
    [listaPoziomow addObject:tlo];
    return tlo;
}

@end
